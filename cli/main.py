import click
import json
import os
import shutil
from pyfiglet import Figlet
import socket


config_file = os.path.join("config.json")

if os.path.exists(config_file):
    with open(config_file, "r+") as outfile:
            data_file=json.load(outfile)        
            games_supported = data_file['ansible_infos']['games_supported']

template_config_file = os.path.join("template_config.json")
generated_folder = os.path.join("generated_files")

root_dir = os.path.abspath("..")
cli_dir = os.path.join(root_dir, "cli")
packer_dir = os.path.join(root_dir, "packer")
terraform_dir = os.path.join(root_dir, "terraform")
ansible_dir = os.path.join(root_dir, "ansible")

# config_file_ci = os.path.join(root_dir, '..', 'config.json') # CI purpose

if not os.path.exists(config_file):
    shutil.copy(template_config_file, config_file)
if not os.path.exists(generated_folder):
    os.mkdir(generated_folder)

@click.group()
def main():
    """
    CLI for Donk'LAN tools by Donk'esport club !
    """
    pass


@main.command()
def apply():
    """Move all generated files in specific directory"""

    prefix = "cli-file-"

    for root,dirs,files in os.walk(generated_folder):
        for file in files:
            print("DEBUG : {}".format(file))
            if "credentials.pkr.hcl" in file:
                shutil.copy(os.path.join(generated_folder, file), os.path.join(packer_dir, file))
            elif "credentials.tfvars" in file:
                shutil.copy(os.path.join(generated_folder, file), os.path.join(terraform_dir, file))
            elif "auto.pkrvars.hcl" in file:
                print("DEBUG : {}".format(file))
                name = file.split(".")
                name = name[0].replace(prefix, "")
                print("DEBUG : {}".format(name))
                
                shutil.copy(os.path.join(generated_folder, file), os.path.join(packer_dir, name, file))

            if "auto.tfvars" in file:
                name = file.split(".")
                name = name[0].replace(prefix, "")
                shutil.copy(os.path.join(generated_folder, file), os.path.join(terraform_dir, name, file))

    click.echo('Moving files..')




@main.command()
def run():
    """Execute all commands and create the Donk'Lan environnement"""
    
    # Variables définitions
    # Phase 1
    packer_cmds = ["packer build -var-file='./cli-file-credentials.pkr.hcl' ./pfsense",
                   "packer build -var-file='./cli-file-credentials.pkr.hcl' ./ubuntu-server-jammy-base"]

    # Phase 2+3+4
    terraform_cmds = ["terraform init",
                      "terraform apply -auto-approve -var-file='../cli-file-credentials.tfvars'"]

    # Phase 2 
    pfsense_cmd = 'ansible-playbook pfsense.yaml'

    # Phase 3
    registry_cmds = ['ansible-playbook registry.yaml --tags configure_host',
                     'ansible-playbook registry.yaml --tags pull_docker_images',
                     'ansible-playbook dnsmasq.yaml --extra-vars "dns_upstream=1.1.1.1"']

    monitoring_cmds = ['ansible-playbook monitoring.yaml --tags install-monitoring-stack --extra-vars "loki_ip=10.50.11.100"', 
                       'ansible-playbook monitoring.yaml --tags copy-sysfiles --extra-vars "loki_ip=10.50.11.100"', 
                       'ansible-playbook monitoring.yaml --tags post-install-server --extra-vars "loki_ip=10.50.11.100"', 
                       'ansible-playbook configure_monitoring.yaml']
    
    # Phase 4
    orchestrator_cmds = ["ansible-playbook consul.yaml", 
                         "ansible-playbook nomad.yaml",
                         "ansible-playbook registry.yaml --tags configure_nomad"] 
    # Phase 5
    traefik_cmd = 'ansible-playbook start_game.yml --tags start_job_nomad --extra-vars "game_name=traefik"'
    website_cmd = 'ansible-playbook webserver.yaml --extra-vars "source_folder=../res/website" --extra-vars "nomad_server_ip=10.50.12.11"'
    freeradius_cmd = 'ansible-playbook freeradius.yaml --extra-vars "source_folder=../res/infra_conf_files/freeradius" --extra-vars "nomad_server_ip=10.50.12.11"'

    # Phase 6
    copy_file_cmds = 'ansible-playbook start_game.yml --tags copy_files_nomad --extra-vars "source_folder={}"' # arg = donk-lan/game_conf_file/<game_name>/
    start_games_cmds = 'ansible-playbook start_game.yml --tags start_job_nomad --extra-vars "game_name={}"' # arg = donk-lan/template/<game_name>.nomad

    # Post install
    postinstall_cmds = ["ansible-playbook monitoring.yaml --tags install-prometheus-agents-promtail",
                        "ansible-playbook monitoring.yaml --tags post-install-agent"]
      
    # Phase 1 Building templates (Pfsense + Ubuntu)
    # packer_cmds = ["packer build -var-file='./cli-file-credentials.pkr.hcl' ./pfsense"] # TEMP
    os.chdir(packer_dir)
    for cmd in packer_cmds:
        print("DEBUG : Executing cmd : {}".format(cmd))
        os.system(cmd)

    # Phase 2 : Deploying network (pfsense)
    # Phase 2.1 Terraform pfsense
    os.chdir(terraform_dir)
    os.chdir("firewall")
    for cmd in terraform_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))

    # Phase 2.2 Ansible pfsense
    os.chdir(ansible_dir)
    os.system(pfsense_cmd)


    # Phase 3 : Deploying core VMs (dns/registry + monitoring)
    # Phase 3.1 Terraform dns/registry 
    os.chdir(terraform_dir)
    os.chdir("registry")
    for cmd in terraform_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))

    # # Phase 3.2 Ansible dns/registry 
    os.chdir(ansible_dir)
    for cmd in registry_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))

    # Phase 3.3 Terraform monitoring
    os.chdir(terraform_dir)
    os.chdir("monitoring")
    for cmd in terraform_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))

    # Phase 3.4 Ansible monitoring
    os.chdir(ansible_dir)
    for cmd in monitoring_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))

    # Phase 4 : Deploying orchestrator
    # Phase 4.1 Terraform consul + nomad
    os.chdir(terraform_dir)
    os.chdir("ubuntu-consul-server")
    for cmd in terraform_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))
        
    os.chdir(terraform_dir)
    os.chdir("ubuntu-nomad-server")
    for cmd in terraform_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))
    
    # Phase 4.2 Ansible consul + nomad
    os.chdir(ansible_dir)
    for cmd in orchestrator_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))


    # Phase 5 : Deploying default automated core services
    
    # Phase 5.1 Ansible for traefik  
    os.chdir(ansible_dir)  
    os.system(traefik_cmd)
    print("DEBUG : Executing cmd : {}".format(traefik_cmd))

    
    # Phase 5.2 Ansible for webserver
    os.system(website_cmd)
    print("DEBUG : Executing cmd : {}".format(website_cmd))


    # Phase 5.3 Ansible for captif portal   
    os.system(freeradius_cmd)
    print("DEBUG : Executing cmd : {}".format(freeradius_cmd))

    
    
    # config_file = config_file_ci # TEMP

    # Phase  6 : Deploying selected games
    os.chdir(cli_dir)
    with open(config_file, "r+") as config: 
        data_file=json.load(config)
        games_selected = data_file["ansible_infos"]["games_selected"]

    # Specific commands for games
    os.chdir(ansible_dir)
    for game in games_selected:
        # check folder exists
        game_folder = os.path.join(root_dir, 'res', 'games_conf_files', game['name'])
        
        if os.path.exists(game_folder):
            os.system(copy_file_cmds.format(game_folder))
            os.system(start_games_cmds.format(game['name']))
            print("DEBUG : Executing cmd : {}".format(copy_file_cmds.format(game_folder)))
            print("DEBUG : Executing cmd : {}".format(start_games_cmds.format(game['name'])))

        else:
            print("Error : No game folder founded for {}".format(game['name']))
            print("See documentation for more details.")

    # Post install
    os.chdir(ansible_dir)
    for cmd in postinstall_cmds:
        os.system(cmd)
        print("DEBUG : Executing cmd : {}".format(cmd))







@main.command()
def build():
    """Build all files from config.json"""

    # config_file = config_file_ci # TEMP


    with open(config_file, "r+") as config: 
        data_file=json.load(config)

        # Packer Creds
        packer_configuration = data_file["packer_infos"]["creds"]   
        with open(os.path.join(generated_folder,"cli-file-credentials.pkr.hcl"), 'w') as file:
            for keys in packer_configuration.keys():
                file.write('{}="{}"\n'.format(keys,packer_configuration[keys]))

        # Terraform Creds
        terraform_configuration = data_file["terraform_infos"]["creds"]   
        with open(os.path.join(generated_folder,"cli-file-credentials.tfvars"), 'w') as file:
            for keys in terraform_configuration.keys():
                file.write('{}="{}"\n'.format(keys,terraform_configuration[keys]))


        # Packer varfiles
        packer_infos = data_file["packer_infos"]   

        proxmox_node = packer_infos["proxmox_node"]
        
        template_deploy = packer_infos["template_deploy"]

        for template_infos in template_deploy:
            name = template_infos['name']
            with open(os.path.join(generated_folder,"cli-file-"+name+".auto.pkrvars.hcl"), 'w') as file:
                # file.write("vmid=0\n") # vmid provide by config.json
                for key in template_infos.keys():
                    if key == "name": # do not write this key:value
                        continue
                    file.write('{}="{}"\n'.format(key, template_infos[key]))
                file.write('node="{}"\n'.format(proxmox_node))

                if name == 'ubuntu-server-jammy-base':
                    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                    s.connect(("8.8.8.8", 80))
                    local_ip = s.getsockname()[0]
                    s.close()   
                    file.write('admin_ip="{}"\n'.format(local_ip))

        # Getting SSH key content for packer connection
        ssh_key = os.path.join(os.path.expanduser("~"), ".ssh", "id_ed25519_ansible.pub")
        print(ssh_key)
        if os.path.isfile(ssh_key):
            print(ssh_key)
            with open(ssh_key, "r") as f:
                data = f.readline()

            with open(os.path.join(generated_folder,"cli-file-pfsense.auto.pkrvars.hcl"), 'a') as file:   
                file.write('ssh_key="{}"'.format(data.strip()))

            with open(os.path.join(packer_dir,"ubuntu-server-jammy-base", "http", "user-data"), 'a') as file:   
                file.write('          - {}\n'.format(data.strip()))

        # Terraform varfiles
        terraform_infos = data_file["terraform_infos"]

        dns_server = terraform_infos["dns_server"]
        user = terraform_infos["user"]
        proxmox_node = terraform_infos["proxmox_node"]
        
        vm_deploy = terraform_infos["vm_deploy"]

        for vm_infos in vm_deploy:
            current_type = vm_infos['type']

            ips = list()
            hostnames = list()
            gateways  = list()
            bridges = list()

            rams = list()
            cores = list()


            with open(os.path.join(generated_folder,"cli-file-"+current_type+".auto.tfvars"), 'w') as file:
                file.write("vmid=0\n") # auto increment
                for vm_infos2 in vm_deploy:
                    if current_type == vm_infos2['type']:
                        # file.write(str(vm_infos2))
                        for keys in vm_infos2.keys():
                            # list of str
                            if keys == "name":
                                hostnames.append(vm_infos2[keys])
                            if keys == "ip_address":
                                ips.append(vm_infos2[keys])
                            if keys == "gateway":
                                gateways.append(vm_infos2[keys])
                            if keys == "bridge":
                                bridges.append(vm_infos2[keys])
                            # list of in
                            if keys == "ram":
                                rams.append(int(vm_infos2[keys]))
                            if keys == "core":
                                cores.append(int(vm_infos2[keys]))
                
                if hostnames == ["pfsense"]:
                    ips = ips.pop()
                    bridges = bridges.pop()

                file.write('hostnames={}\n'.format(hostnames).replace("'", '"'))
                file.write('ips={}\n'.format(ips).replace("'", '"'))
                file.write('gateways={}\n'.format(gateways).replace("'", '"'))
                file.write('bridges={}\n'.format(bridges).replace("'", '"'))
                file.write('rams={}\n'.format(rams))
                file.write('cores={}\n'.format(cores))
                file.write('user="{}"\n'.format(user))
                file.write('node="{}"\n'.format(proxmox_node))

                if hostnames == ["registry"]:
                    file.write('dns_server="{}"\n'.format("1.1.1.1"))
                else:
                    file.write('dns_server="{}"\n'.format(dns_server))




        # Ansible inventory
        # todo

            
     
    click.echo("Building variables files...") 



@main.command()
@click.argument('proxmox_api_token_id')
@click.argument('proxmox_api_token_secret')
def packer(proxmox_api_token_id, proxmox_api_token_secret):
    """Give informations about packer user"""
 

    with open(config_file, "r+") as outfile:
        data_file=json.load(outfile)
        packer_infos = data_file['packer_infos']['creds']
        packer_infos["proxmox_api_token_id"] = proxmox_api_token_id
        packer_infos["proxmox_api_token_secret"] = proxmox_api_token_secret

        outfile.seek(0)
        json.dump(data_file, outfile, indent=4)
        outfile.truncate()

    click.echo("Packer user configuration : ")
    click.echo("proxmox_api_token_id={} \nproxmox_api_token_secret={}".format(proxmox_api_token_id, proxmox_api_token_secret))

@main.command()

@click.argument('proxmox_api_token_id')
@click.argument('proxmox_api_token_secret')
def terraform(proxmox_api_token_id, proxmox_api_token_secret):
    """Give informations about terraform user"""
 

    with open(config_file, "r+") as outfile:
        data_file=json.load(outfile)
        terraform_infos = data_file['terraform_infos']['creds']
        terraform_infos["proxmox_api_token_id"] = proxmox_api_token_id
        terraform_infos["proxmox_api_token_secret"] = proxmox_api_token_secret

        outfile.seek(0)
        json.dump(data_file, outfile, indent=4)
        outfile.truncate()
    
    click.echo("Terraform user configuration : ")
    click.echo("proxmox_api_token_id={} \nproxmox_api_token_secret={}".format(proxmox_api_token_id, proxmox_api_token_secret))


@main.command()
@click.argument('proxmox_ip') 
@click.argument('proxmox_node') 
def proxmox(proxmox_ip, proxmox_node):
    """Give informations about proxmox server"""
    with open(config_file, "r+") as outfile:
        data_file=json.load(outfile)

        proxmox_api_url = f'https://{proxmox_ip}:8006/api2/json'
        
        packer_infos = data_file['packer_infos']
        packer_infos['creds']["proxmox_api_url"] = proxmox_api_url  
        packer_infos["proxmox_node"] = proxmox_node    

        terraform_infos = data_file['terraform_infos']
        terraform_infos['creds']["proxmox_api_url"] = proxmox_api_url
        terraform_infos["proxmox_node"] = proxmox_node

        outfile.seek(0)
        json.dump(data_file, outfile, indent=4)
        outfile.truncate()

    click.echo("Proxmox configuration")
    click.echo("proxmox_api_url={} \nproxmox_node={}".format(proxmox_api_url, proxmox_node))

        



@main.command()
@click.argument('game_name')
def add(game_name):
    """Adding game to deploy in Donk'LAN"""

    if {"name": game_name} not in games_supported:
        click.echo("Selected game not available")
        return 1
    
    with open(config_file, "r+") as outfile:
        data_file=json.load(outfile)        
        games_selected = data_file['ansible_infos']['games_selected']

        if {"name":game_name} in games_selected:
            click.echo("Game already selected")
            return 0

        games_selected.append({"name":game_name})

        outfile.seek(0)
        json.dump(data_file, outfile, indent=4)
        outfile.truncate()

    
    click.echo("Wanted games are %s " % games_selected) 


@main.command()   
def reset():
    """Delete config.json file and all files in generated_files"""

    if os.path.exists(config_file):
        os.remove(config_file)
    if os.path.exists(generated_folder):
        shutil.rmtree(generated_folder)

    click.echo("All files have been deleted")

@main.command()
def show():

    """Show all games Donk'LAN can deploy"""
    click.echo("Games supported : ") 
    for game in games_supported:
        click.echo(game) 


if __name__ == "__main__":
    f = Figlet(font='slant')
    print(f.renderText("Donk'LAN Tools"))
    main()
