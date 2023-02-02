import csv
import secrets
import string
from fpdf import FPDF # pip install fpdf
import re
from unidecode import unidecode
import hashlib

input_filename = 'input.csv'
create_filename = 'forti_create.txt'
delete_filename = 'forti_delete.txt'
pdf_filename='creds.pdf'
radius_filename='users.other'

fortigate = True
freeradius = True


def get_username():
    username_lst = list()
    try:
        with open(input_filename, 'r') as input:
            # csv obj
            obj = csv.DictReader(input)

            for line in obj:

                # get info
                nom = line['Nom'] # warning user input
                prenom = line['Prénom'] # warning user input
                            
                nom = re.sub(r"[^a-z]","", unidecode(nom.lower()))
                prenom = re.sub(r"[^a-z]","", unidecode(prenom.lower()))

                # create username
                username = nom[0].upper() + nom[1:] + prenom[0].upper()

                username_lst.append(username)
            
        username_lst.sort()
    except:
        print("File {} not found".format(input_filename))

    return username_lst

def set_password(nb_pass):
    # generate password

    password_lst = list()

    pwd_length = 8
    letters = string.ascii_letters
    digits = string.digits
    alphabet = letters + digits + digits

    for i in range(nb_pass):
        password = ''
        for i in range(pwd_length):
            password += ''.join(secrets.choice(alphabet))
        password_lst.append(password)
    return password_lst

def create_user_cli(username_lst, password_lst):
    with open(create_filename, 'w') as output_file:
        output_file.write("config user local\n")

        for i in range(len(username_lst)):

            # format cli instruction for creation
            skel = 'edit "<username>" \nset type password \nset passwd <password> \nnext\n' 
            skel = skel.replace("<username>", username_lst[i])
            skel = skel.replace("<password>", password_lst[i])

            output_file.write(skel)  

        output_file.write('end\n')   

    return 0

def delete_user_cli(username_lst):
    with open(delete_filename, 'a') as output_file:
        output_file.write("config user local\n")

        for username in username_lst:
            # format cli instruction for destruction
            skel2 = 'delete <username>\n'
            skel2 = skel2.replace("<username>", username)

            output_file.write(skel2) 
        
        output_file.write('end\n')

    return 0 

def add_usergroup_cli(username_lst):
    # User captif
    with open(create_filename, 'a') as output_file:
        output_file.write('config user group\n')
        output_file.write('edit joueurs_portail_captif\n')

        skel = "set member <username>\n"
        skel = skel.replace("<username>", " ".join(username_lst))        
        
        output_file.write(skel)
        output_file.write('end\n')
    return 0

def del_usergoup_cli():
    with open(delete_filename, 'w') as output_file:
        output_file.write('config user group\n')
        output_file.write('edit joueurs_portail_captif\n')
        skel = "unset member\n"
        output_file.write(skel)
        output_file.write('end\n')


    return 0

def create_pdf(username_lst, password_lst):
    pdf = FPDF(orientation='P', unit='mm', format='A4')

    pdf.add_page() 
    pdf.set_font("Arial", size = 15)

    cpt = 0
    for i in range(len(username_lst)):        
        if cpt==9: # 9 identifiant par page 
            pdf.add_page()
            cpt = 0
        cpt += 1

        pdf.set_font("Arial", size = 15)
       
        creds = "Identifiant : " + username_lst[i] + " Mot de passe : " + password_lst[i]        
        pdf.cell(200, 10, txt = creds,
            ln = 1)
        
        pdf.set_font("Arial", size = 9)
        pdf.cell(200, 8, txt = "En me connectant, je reconnais avoir lu et m'engage à respecter la charte informatique de l'UBS.",
            ln = 1)
        
        pdf.set_font("Arial", size = 15)

        if cpt!=9: # Dernier -- inutile   
            pdf.cell(200, 10, txt = "-"*40,
                ln = 1)

        

    pdf.output(pdf_filename)

    return 0

def create_user_radius(username_lst, password_lst):
    with open(radius_filename, 'w') as output_file:
        for i in range(len(username_lst)):

            cipher = hashlib.sha256(password_lst[i].encode('utf-8')).hexdigest()
            
            skel = '<username>\tPassword-With-Header := "{sha256}<cipher>"\n' 
            skel = skel.replace("<username>", username_lst[i])
            skel = skel.replace("<cipher>", cipher)

            output_file.write(skel)  

    return 0


def main():

    username_lst = get_username()
    password_lst = set_password(len(username_lst))


    if fortigate:
        print("Fortigate enable")
        create_user_cli(username_lst, password_lst)
        add_usergroup_cli(username_lst)

        del_usergoup_cli()
        delete_user_cli(username_lst)
        create_pdf(username_lst, password_lst)

    if freeradius:
        print("Freeradius enable")
        create_user_radius(username_lst, password_lst)
        create_pdf(username_lst, password_lst)


if __name__ == "__main__":
    main()
