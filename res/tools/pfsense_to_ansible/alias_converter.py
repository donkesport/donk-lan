from bs4 import BeautifulSoup

input_file = "config-pfsense.donk.lan-20221223211741.xml"

# input_file = 'sample.xml'

alias_file = 'alias.yaml'
rules_file = 'rules.yaml'

alias_skel = "- name: <name>\n  pfsensible.core.pfsense_alias:\n    name: <name>\n    state: present\n    type: <type>\n    address: <address>\n\n"
rule_skel = "- name: <descr>\n  pfsensible.core.pfsense_rule:\n    name: <descr>\n    action: <action>\n    interface: <int_in>\n    ipprotocol: <ip_prot>\n    protocol: <prot>\n    source: <ip_src>\n    destination:  <ip_dst>\n    destination_port: <port_dst>\n    state: present\n\n"
 
interfaces_alias = {
    'wan' : '10_DONK_interco',
    'lan' : '11_SRV_Monitoring', 
    'opt1': '12_SRV_Automatisation',
    'opt2': '13_SRV_Infra',
    'opt3': '14_SRV_Games',
    'opt4': '31_STA_ADMIN',
    'opt5': '32_STA_Joueurs'
}

ip_alias = {
    'wanip' : '10_DONK_interco_address',
    'lanip' : '11_SRV_Monitoring_address',
    'opt1ip' : '12_SRV_Automatisation_address',
    'opt2ip' : '13_SRV_Infra_address',
    'opt3ip' : '14_SRV_Games_address',
    'opt4ip' : '31_STA_ADMIN_address',
    'opt5ip' : '32_STA_Joueurs_address'
}

def alias():

    f = open(alias_file, 'w')

    with open(input_file, 'r') as file:
        data = file.read()

        soup = BeautifulSoup(data, 'xml')

        aliases = soup.find_all("alias")

        for alias in aliases:
            name = alias.find('name').text
            type = alias.find('type').text
            address = alias.find('address').text
            # print(name, type, address)

            response = alias_skel.replace("<name>", name)
            response = response.replace("<type>", type)
            response = response.replace("<address>", address)
            

            f.write(response)

    f.close()      


def rules():
    f = open(rules_file, 'w')

    with open(input_file, 'r') as file:
        data = file.read()

        soup = BeautifulSoup(data, 'xml')

        rules = soup.find_all("rule")

        for rule in rules:

            port_dst = "any" # default
            prot = "any" # default
 


            action = rule.find('type').text
            int_in  = rule.find('interface').text
            ip_prot = rule.find('ipprotocol').text
            
            if rule.find('protocol'):
                prot = rule.find('protocol').text
            

            if prot == 'icmp':
                pass

            source = rule.find('source') # address ou network
            # print(source.find("address").text)
            if source.find('any'):
                ip_src = 'any'
            if source.find('network'):
                ip_src = source.find('network').text
            if source.find('address'):
                ip_src = source.find('address').text

            
            destination = rule.find('destination') # network/address + port

            # print(destination)
            if destination.find("any"):
                ip_dst = 'any'                
            if destination.find('network'):
                ip_dst = destination.find('network').text
            if destination.find('address'):
                ip_dst = destination.find('address').text
            if destination.find('port'):
                port_dst = destination.find('port').text

            print(action, int_in, ip_prot, prot, source, destination)

            
            descr = rule.find('descr').text

            descr = descr.replace(':', '')

            if descr == "":
                descr = "TODO"

            if int_in in interfaces_alias.keys():
                int_in = interfaces_alias[int_in]

            if ip_src in interfaces_alias.keys():
                ip_src = interfaces_alias[ip_src]

            if ip_dst in interfaces_alias.keys():
                ip_dst = interfaces_alias[ip_dst]

            if ip_src in ip_alias.keys():
                ip_src = ip_alias[ip_src]

            if ip_dst in ip_alias.keys():
                ip_dst = ip_alias[ip_dst]

            print(descr)

            response = rule_skel.replace("<action>", action)
            response = response.replace("<int_in>", int_in)
            response = response.replace("<ip_prot>", ip_prot)
            response = response.replace("<prot>", prot)
            response = response.replace("<ip_src>", ip_src)
            response = response.replace("<ip_dst>", ip_dst)
            
            if port_dst == "any":
                response = response.replace("destination_port: <port_dst>\n    ", "")
            else:
                response = response.replace("<port_dst>", port_dst)
            
            response = response.replace("<descr>", descr)
            

            f.write(response)

    f.close()      


def main():
    # alias()
    rules()
            
main()

