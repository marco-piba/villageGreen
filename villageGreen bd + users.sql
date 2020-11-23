-- ACCEDER A LA BASE DE DONNEE --
USE village_green ;


-- CREATION DES TABLES --

DROP TABLE IF EXISTS rubriques;
CREATE TABLE IF NOT EXISTS rubriques(
   rub_id INT NOT NULL AUTO_INCREMENT,
   rub_nom VARCHAR(50) NOT NULL,
   rub_parent_id INT,
   PRIMARY KEY(rub_id),
   FOREIGN KEY(rub_parent_id) REFERENCES rubriques(rub_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS coefficient_client;
CREATE TABLE IF NOT EXISTS coefficient_client(
   coeff_prix DECIMAL(2,1),
   coeff_lib VARCHAR(15) NOT NULL,
   PRIMARY KEY(coeff_prix)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS commerciaux;
CREATE TABLE IF NOT EXISTS commerciaux(
   commerc_id INT NOT NULL AUTO_INCREMENT,
   commerc_nom VARCHAR(50) NOT NULL,
   commerc_prenom VARCHAR(50) NOT NULL,
   PRIMARY KEY(commerc_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS pays;
CREATE TABLE IF NOT EXISTS pays(
   pays_sig VARCHAR(2),
   pays_nom VARCHAR(50) NOT NULL,
   PRIMARY KEY(pays_sig)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS livraison;
CREATE TABLE IF NOT EXISTS livraison(
   livr_id INT NOT NULL AUTO_INCREMENT,
   livr_adress VARCHAR(50) NOT NULL,
   livr_date DATE,
   livr_details VARCHAR(50) NOT NULL,
   livr_status VARCHAR(30) NOT NULL,
   PRIMARY KEY(livr_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS fournisseurs;
CREATE TABLE IF NOT EXISTS fournisseurs(
   four_id int NOT NULL AUTO_INCREMENT,
   four_nom VARCHAR(50) NOT NULL,
   four_adress VARCHAR(150) NOT NULL,
   four_postal VARCHAR(10) NOT NULL,
   four_contact VARCHAR(50) NOT NULL,
   four_phone INT NOT NULL,
   four_mail VARCHAR(50) NOT NULL,
   four_pays_sig VARCHAR(2) NOT NULL,
   PRIMARY KEY(four_id),
   FOREIGN KEY(four_pays_sig) REFERENCES pays(pays_sig)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS clients;
CREATE TABLE IF NOT EXISTS clients(
   cli_ref VARCHAR(5),
   cli_nom VARCHAR(50) NOT NULL,
   cli_prenom VARCHAR(50),
   cli_adress VARCHAR(150) NOT NULL,
   cli_postal VARCHAR(10) NOT NULL,
   cli_ville VARCHAR(50) NOT NULL,
   cli_mail VARCHAR(50) NOT NULL,
   cli_phone INT NOT NULL,
   cli_pays_sig VARCHAR(2) NOT NULL,
   cli_commerc_id INT NOT NULL,
   cli_coeff_prix DECIMAL(2,1) NOT NULL,
   PRIMARY KEY(cli_ref),
   FOREIGN KEY(cli_pays_sig) REFERENCES pays(pays_sig),
   FOREIGN KEY(cli_commerc_id) REFERENCES commerciaux(commerc_id),
   FOREIGN KEY(cli_coeff_prix) REFERENCES coefficient_client(coeff_prix)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS commande;
CREATE TABLE IF NOT EXISTS commande(
   com_ref VARCHAR(10),
   com_date DATE NOT NULL,
   com_cli_ref VARCHAR(5) NOT NULL,
   PRIMARY KEY(com_ref),
   FOREIGN KEY(com_cli_ref) REFERENCES clients(cli_ref)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS facture;
CREATE TABLE IF NOT EXISTS facture(
   fact_ref CHAR(7),
   fact_adress VARCHAR(150) NOT NULL,
   fact_paym_date DATE NOT NULL,
   fact_cmd_total DECIMAL(7,2) NOT NULL,
   fact_date DATE NOT NULL,
   fact_tot_discount INT,
   fact_coeff_prix DECIMAL(2,1) NOT NULL,
   fact_com_ref VARCHAR(10) NOT NULL,
   PRIMARY KEY(fact_ref),
   FOREIGN KEY(fact_coeff_prix) REFERENCES coefficient_client(coeff_prix),
   FOREIGN KEY(fact_com_ref) REFERENCES commande(com_ref)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS produits;
CREATE TABLE IF NOT EXISTS produits(
   pro_ref CHAR(5),
   pro_lib VARCHAR(30) NOT NULL,
   pro_desc VARCHAR(300) NOT NULL,
   pro_unit_prix DECIMAL(7,2),
   pro_photo VARCHAR(4),
   pro_stock INT NOT NULL,
   pro_enligne BINARY NOT NULL,
   pro_rub_id INT NOT NULL,
   pro_four_id INT NOT NULL,
   PRIMARY KEY(pro_ref),
   FOREIGN KEY(pro_rub_id) REFERENCES rubriques(rub_id),
   FOREIGN KEY(pro_four_id) REFERENCES fournisseurs(four_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS ligne_de_commande;
CREATE TABLE IF NOT EXISTS ligne_de_commande(
   lign_cmd_id INT NOT NULL AUTO_INCREMENT,
   lign_cmd_unitprix DECIMAL(7,2) NOT NULL,
   lign_cmd_qtite INT NOT NULL,
   lign_cmd_total_tva INT NOT NULL,
   lign_cmd_pro_ref CHAR(5) NOT NULL,
   lign_cmd_com_ref VARCHAR(10) NOT NULL,
   PRIMARY KEY(lign_cmd_id),
   FOREIGN KEY(lign_cmd_pro_ref) REFERENCES produits(pro_ref),
   FOREIGN KEY(lign_cmd_com_ref) REFERENCES commande(com_ref)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS ligne_de_livraison;
CREATE TABLE IF NOT EXISTS ligne_de_livraison(
   lign_livr_id INT NOT NULL AUTO_INCREMENT,
   lign_livr_lign_cmd_id INT NOT NULL,
   lign_livr_livr_id INT NOT NULL,
   PRIMARY KEY(lign_livr_id),
   FOREIGN KEY(lign_livr_lign_cmd_id) REFERENCES ligne_de_commande(lign_cmd_id),
   FOREIGN KEY(lign_livr_livr_id) REFERENCES livraison(livr_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- CREATION DES PROFILS UTILISATEURS --

-- PROFIL VISITEUR --
CREATE USER IF NOT EXISTS 'visiteur'@'%' IDENTIFIED BY 'visiteur1234';

-- PROFIL CLIENT --
CREATE USER IF NOT EXISTS 'client'@'%' IDENTIFIED BY 'client4123';

-- PROFIL GESTION --
CREATE USER IF NOT EXISTS 'gestion'@'%' IDENTIFIED BY 'gestion3412';

-- PROFIL ADMINISTRATEUR --
CREATE USER IF NOT EXISTS 'administrateur'@'%' IDENTIFIED BY 'administrateur2431';


-- CREATION DES ROLES --
CREATE ROLE IF NOT EXISTS 'r_villagegreen_visiteur'@'localhost';
CREATE ROLE IF NOT EXISTS 'r_villagegreen_client'@'localhost';
CREATE ROLE IF NOT EXISTS 'r_villagegreen_gestion'@'localhost';
CREATE ROLE IF NOT EXISTS 'r_villagegreen_administrateur'@'localhost';

-- ATTRIBUTION DES PRIVILEGES POUR CHAQUE ROLE --
GRANT SELECT 
ON village_green.produits
to 'r_villagegreen_visiteur'@'localhost';

GRANT SELECT 
ON village_green.*
to 'r_villagegreen_client'@'localhost';

GRANT SELECT ,UPDATE ,INSERT
ON village_green.commande
to 'r_villagegreen_client'@'localhost';

GRANT SELECT ,UPDATE ,INSERT
ON village_green.clients
to 'r_villagegreen_client'@'localhost';

GRANT ALL PRIVILEGES
ON village_green.*
to 'r_villagegreen_gestion'@'localhost';

GRANT ALL PRIVILEGES
ON *.*
to 'r_villagegreen_administrateur'@'localhost';



-- AFFECTER ROLE AUX UTILISATEURS --

GRANT 'r_villagegreen_visiteur'@'localhost'
to 'visiteur'@'%';

GRANT 'r_villagegreen_client'@'localhost'
TO 'client'@'%';

GRANT 'r_villagegreen_gestion'@'localhost'
TO 'gestion'@'%';

GRANT 'r_villagegreen_administrateur'@'localhost'
TO 'administrateur'@'%';


-- ALIMENTER LES TABLES --

-- alimenter pays --

INSERT INTO `pays` (`pays_sig`, `pays_nom`) VALUES
('AD', 'Andorre'),
('AE', 'Emirats Arabes Unis'),
('AF', 'Afghanistan'),
('AG', 'Antigua-et-Barbuda'),
('AI', 'Anguilla'),
('AL', 'Albanie'),
('AM', 'Arménie'),
('AN', 'Antilles Nederlandaises'),
('AO', 'Angola'),
('AQ', 'Antarctique'),
('AR', 'Argentine'),
('AS', 'Samoa Américaines'),
('AT', 'Autriche'),
('AU', 'Australie'),
('AW', 'Aruba'),
('AX', 'Iles Ãland'),
('AZ', 'Azerbaidjan'),
('BA', 'Bosnie-Herzégovine'),
('BB', 'Barbade'),
('BD', 'Bangladesh'),
('BE', 'Belgique'),
('BF', 'Burkina Faso'),
('BG', 'Bulgarie'),
('BH', 'Bahrein'),
('BI', 'Burundi'),
('BJ', 'Bénin'),
('BM', 'Bermudes'),
('BN', 'Brunei Darussalam'),
('BO', 'Bolivie'),
('BR', 'Brésil'),
('BS', 'Bahamas'),
('BT', 'Bhoutan'),
('BV', 'Ile Bouvet'),
('BW', 'Botswana'),
('BY', 'Bélarus'),
('BZ', 'Belize'),
('CA', 'Canada'),
('CC', 'Iles Cocos (Keeling)'),
('CD', 'République Démocratique du Congo'),
('CF', 'République Centrafricaine'),
('CG', 'République du Congo'),
('CH', 'Suisse'),
('CI', 'Cote d`Ivoire'),
('CK', 'Iles Cook'),
('CL', 'Chili'),
('CM', 'Cameroun'),
('CN', 'Chine'),
('CO', 'Colombie'),
('CR', 'Costa Rica'),
('CS', 'Serbie-et-Monténégro'),
('CU', 'Cuba'),
('CV', 'Cap-vert'),
('CX', 'Ile Christmas'),
('CY', 'Chypre'),
('CZ', 'République Tchèque'),
('DE', 'Allemagne'),
('DJ', 'Djibouti'),
('DK', 'Danemark'),
('DM', 'Dominique'),
('DO', 'République Dominicaine'),
('DZ', 'Algérie'),
('EC', 'Equateur'),
('EE', 'Estonie'),
('EG', 'Egypte'),
('EH', 'Sahara Occidental'),
('ER', 'Erythrée'),
('ES', 'Espagne'),
('ET', 'Ethiopie'),
('FI', 'Finlande'),
('FJ', 'Fidji'),
('FK', 'Iles (malvinas) Falkland'),
('FM', 'Etats Fédérés de Micronésie'),
('FO', 'Iles Féroé'),
('FR', 'France'),
('GA', 'Gabon'),
('GB', 'Royaume-Uni'),
('GD', 'Grenade'),
('GE', 'Géorgie'),
('GF', 'Guyane Française'),
('GH', 'Ghana'),
('GI', 'Gibraltar'),
('GL', 'Groenland'),
('GM', 'Gambie'),
('GN', 'Guinée'),
('GP', 'Guadeloupe'),
('GQ', 'Guinée Equatoriale'),
('GR', 'Grèce'),
('GS', 'Géorgie du Sud et les iles Sandwich du Sud'),
('GT', 'Guatemala'),
('GU', 'Guam'),
('GW', 'Guinée-Bissau'),
('GY', 'Guyana'),
('HK', 'Hong-Kong'),
('HM', 'Iles Heard et Mcdonald'),
('HN', 'Honduras'),
('HR', 'Croatie'),
('HT', 'Haiti'),
('HU', 'Hongrie'),
('ID', 'Indonésie'),
('IE', 'Irlande'),
('IL', 'Israel'),
('IM', 'Ile de Man'),
('IN', 'Inde'),
('IO', 'Territoire Britannique de l`Océan Indien'),
('IQ', 'Iraq'),
('IR', 'République Islamique d`Iran'),
('IS', 'Islande'),
('IT', 'Italie'),
('JM', 'Jamaique'),
('JO', 'Jordanie'),
('JP', 'Japon'),
('KE', 'Kenya'),
('KG', 'Kirghizistan'),
('KH', 'Cambodge'),
('KI', 'Kiribati'),
('KM', 'Comores'),
('KN', 'Saint-Kitts-et-Nevis'),
('KP', 'République Populaire Démocratique de Corée'),
('KR', 'République de Corée'),
('KW', 'Koweit'),
('KY', 'Iles Caimanes'),
('KZ', 'Kazakhstan'),
('LA', 'République Démocratique Populaire Lao'),
('LB', 'Liban'),
('LC', 'Sainte-Lucie'),
('LI', 'Liechtenstein'),
('LK', 'Sri Lanka'),
('LR', 'Liberia'),
('LS', 'Lesotho'),
('LT', 'Lituanie'),
('LU', 'Luxembourg'),
('LV', 'Lettonie'),
('LY', 'Jamahiriya Arabe Libyenne'),
('MA', 'Maroc'),
('MC', 'Monaco'),
('MD', 'République de Moldova'),
('MG', 'Madagascar'),
('MH', 'Iles Marshall'),
('MK', 'L`ex-RÃ©publique Yougoslave de Macédoine'),
('ML', 'Mali'),
('MM', 'Myanmar'),
('MN', 'Mongolie'),
('MO', 'Macao'),
('MP', 'Iles Mariannes du Nord'),
('MQ', 'Martinique'),
('MR', 'Mauritanie'),
('MS', 'Montserrat'),
('MT', 'Malte'),
('MU', 'Maurice'),
('MV', 'Maldives'),
('MW', 'Malawi'),
('MX', 'Mexique'),
('MY', 'Malaisie'),
('MZ', 'Mozambique'),
('NA', 'Namibie'),
('NC', 'Nouvelle-Calédonie'),
('NE', 'Niger'),
('NF', 'Ile Norfolk'),
('NG', 'Nigéria'),
('NI', 'Nicaragua'),
('NL', 'Pays-Bas'),
('NO', 'Norvège'),
('NP', 'Népal'),
('NR', 'Nauru'),
('NU', 'Niue'),
('NZ', 'Nouvelle-Zélande'),
('OM', 'Oman'),
('PA', 'Panama'),
('PE', 'Pérou'),
('PF', 'Polynésie Française'),
('PG', 'Papouasie-Nouvelle-Guinée'),
('PH', 'Philippines'),
('PK', 'Pakistan'),
('PL', 'Pologne'),
('PM', 'Saint-Pierre-et-Miquelon'),
('PN', 'Pitcairn'),
('PR', 'Porto Rico'),
('PS', 'Territoire Palestinien Occupé'),
('PT', 'Portugal'),
('PW', 'Palaos'),
('PY', 'Paraguay'),
('QA', 'Qatar'),
('RE', 'Réunion'),
('RO', 'Roumanie'),
('RU', 'Fédération de Russie'),
('RW', 'Rwanda'),
('SA', 'Arabie Saoudite'),
('SB', 'ÃŽles Salomon'),
('SC', 'Seychelles'),
('SD', 'Soudan'),
('SE', 'Suède'),
('SG', 'Singapour'),
('SH', 'Sainte-Hèlène'),
('SI', 'Slovénie'),
('SJ', 'Svalbard et ile Jan Mayen'),
('SK', 'Slovaquie'),
('SL', 'Sierra Leone'),
('SM', 'Saint-Marin'),
('SN', 'Sénégal'),
('SO', 'Somalie'),
('SR', 'Suriname'),
('ST', 'Sao Tomé-et-Principe'),
('SV', 'El Salvador'),
('SY', 'République Arabe Syrienne'),
('SZ', 'Swaziland'),
('TC', 'Iles Turks et Caiques'),
('TD', 'Tchad'),
('TF', 'Terres Australes Françaises'),
('TG', 'Togo'),
('TH', 'Thailande'),
('TJ', 'Tadjikistan'),
('TK', 'Tokelau'),
('TL', 'Timor-Leste'),
('TM', 'Turkménistan'),
('TN', 'Tunisie'),
('TO', 'Tonga'),
('TR', 'Turquie'),
('TT', 'Trinité-et-Tobago'),
('TV', 'Tuvalu'),
('TW', 'TaÃ¯wan'),
('TZ', 'République-Unie de Tanzanie'),
('UA', 'Ukraine'),
('UG', 'Ouganda'),
('UM', 'Iles Mineures éloignées des états-Unis'),
('US', 'Etats-Unis'),
('UY', 'Uruguay'),
('UZ', 'Ouzbékistan'),
('VA', 'Saint-Siège (état de la Cité du Vatican)'),
('VC', 'Saint-Vincent-et-les Grenadines'),
('VE', 'Venezuela'),
('VG', 'ÃŽles Vierges Britanniques'),
('VI', 'ÃŽles Vierges des états-Unis'),
('VN', 'Viet Nam'),
('VU', 'Vanuatu'),
('WF', 'Wallis et Futuna'),
('WS', 'Samoa'),
('YE', 'Yémen'),
('YT', 'Mayotte'),
('ZA', 'Afrique du Sud'),
('ZM', 'Zambie'),
('ZW', 'Zimbabwe');


-- alimenter fournisseurs --
INSERT INTO `fournisseurs` (`four_id`,`four_nom`,`four_adress`,`four_postal`,`four_contact`,`four_phone`,`four_mail`,`four_pays_sig`) VALUES (1,"Mattis Limited","P.O. Box 556, 8383 In Rd.","297367","Jameson Hayden","0217222076","ac.nulla.In@tinciduntnibhPhasellus.net","AL"),(2,"Fermentum Risus At Corp.","601-3153 Mollis Street","60410","Martina Duke","0183745184","bibendum@eu.edu","BA"),(3,"Proin Vel Limited","239-8067 Sem. Rd.","9515","Hunter Knapp","0112468682","orci.in.consequat@cubilia.com","GR"),(4,"At Velit Pellentesque Ltd","951-4544 Sapien Street","54170","Jordan Carroll","0818876853","mollis.Phasellus.libero@ametdiam.net","TJ"),(5,"Nullam Enim Corporation","Ap #539-1599 Lacus. Rd.","5770","Nash Cherry","0605146613","augue@magnaa.edu","EC"),(6,"Eu Industries","P.O. Box 994, 8615 Lacus. Av.","J9K 3K5","Troy Santiago","0577200999","eget.massa@ettristiquepellentesque.ca","CA"),(7,"Nunc Id Enim Foundation","P.O. Box 546, 7451 Nec St.","92678-45274","Chaney Jefferson","0938657366","ante.Vivamus.non@varius.org","BO"),(8,"Rutrum Corporation","8239 Nibh. Road","431042","Celeste Trevino","0142165835","ultrices.iaculis.odio@vitaepurusgravida.net","QA"),(9,"Dictum Ultricies Inc.","Ap #642-4296 Adipiscing Ave","699227","Beau Gomez","0591664818","luctus.vulputate.nisi@ategestasa.com","JP"),(10,"Ante Bibendum Ullamcorper PC","Ap #117-8507 Et Avenue","61865-05023","Alexandra Fitzpatrick","0567412899","erat@estcongue.ca","CA");
INSERT INTO `fournisseurs` (`four_id`,`four_nom`,`four_adress`,`four_postal`,`four_contact`,`four_phone`,`four_mail`,`four_pays_sig`) VALUES (11,"Rutrum Foundation","Ap #677-5935 Aliquam Rd.","79913","Ivana Cunningham","0707191199","tincidunt.vehicula@risusIn.co.uk","AU"),(12,"Adipiscing Enim Mi Industries","Ap #354-6308 Lorem St.","556921","Zena Wright","0123030122","metus.Vivamus.euismod@mauris.ca","CA"),(13,"Vitae Erat Vivamus Limited","204-3682 Nam Ave","NA54 2YJ","Mia Hunt","0594546563","lobortis@acsemut.com","DE"),(14,"Quis Arcu Industries","Ap #763-9053 Id, St.","065337","Samantha Richardson","0472350893","odio.Etiam@posuerecubiliaCurae.net","AT"),(15,"Egestas Fusce Limited","P.O. Box 537, 8493 Natoque Rd.","40319","Davis Villarreal","0289590267","lacus@iaculis.net","MC"),(16,"Auctor Mauris Vel Corp.","P.O. Box 591, 8016 In Road","8306","Kelsie Reeves","0808430226","fames@auctor.com","MG"),(17,"Odio Semper Cursus LLC","577-616 Risus. St.","16852","Talon Kelley","0123675384","mauris.blandit@euismodac.org","NL"),(18,"Enim Limited","164-8542 Consequat St.","760635","Teagan Eaton","0993184036","sit@vitaeposuereat.co.uk","BA"),(19,"Sodales Mauris Inc.","6084 Molestie Av.","73471","Mia Rodgers","0913766168","mattis.Cras@cursusaenim.com","LK"),(20,"Pede Ac Corp.","P.O. Box 937, 9073 Vitae Ave","V4R 5N7","Portia Branch","0994462288","mollis.non@vitae.org","VE");
INSERT INTO `fournisseurs` (`four_id`,`four_nom`,`four_adress`,`four_postal`,`four_contact`,`four_phone`,`four_mail`,`four_pays_sig`) VALUES (21,"Nec Metus Facilisis Consulting","Ap #148-9841 Dui St.","919280","Kaitlin Hayden","0693525234","nonummy.ac.feugiat@in.net","GE"),(22,"Odio Ltd","9889 Laoreet Av.","906630","Quail Dunn","0678644598","suscipit.nonummy.Fusce@eueuismod.ca","CA"),(23,"Accumsan Sed Facilisis Associates","3825 Morbi Rd.","X58 1UE","Nichole Delacruz","0761785357","In@dolorvitae.org","FR"),(24,"Est Tempor Bibendum Limited","P.O. Box 105, 697 Pretium Rd.","581712","Cora Marshall","0327806633","sem.ut.dolor@vestibulum.org","AI"),(25,"Urna Et Company","145-528 Non, Avenue","75039","Yuli Arnold","0244565983","cursus.Nunc@justoProinnon.net","CI"),(26,"Duis Dignissim Tempor Associates","241-1061 Montes, Av.","228253","Dorian Conway","0939425381","quis.diam@pellentesque.co.uk","IQ"),(27,"Cras Dictum Ultricies Associates","578-1317 Nonummy St.","48994","Kibo Dodson","0978539056","eu.elit.Nulla@scelerisque.co.uk","BA"),(28,"A Corporation","P.O. Box 592, 5838 Fringilla St.","5355","Dustin Benton","0729115959","enim@diamluctuslobortis.net","NG"),(29,"Dolor Incorporated","P.O. Box 299, 2322 Sollicitudin Rd.","22-530","Erica Charles","0434498609","risus.Nunc@purusDuis.co.uk","NC"),(30,"Enim Commodo Inc.","P.O. Box 997, 4538 Dictum Road","08106","Aurelia Webb","0285966462","sit.amet.ultricies@molestie.ca","CA");

-- alimenter rubriques --
INSERT INTO rubriques (`rub_id`,`rub_nom`,`rub_parent_id`) 
values (1,'Accessoires',NULL),(2,'Amplificateurs',NULL),(3,'Baguette direction',NULL),(4,'Batteries',NULL),(5,'Batteries enfants',NULL),(6,'Bruitages',NULL),(7,'Claviers',NULL),(8,'Instruments à cordes',NULL),(9,'Instruments à vent',NULL),(10,'Instruments en Abs',NULL),(11,'Percussions',NULL),(12,'Violons',NULL),(13,'Microphone',NULL);

INSERT INTO rubriques (`rub_id`,`rub_nom`,`rub_parent_id`) 
values ('14','Cordes','1'),('15','Housses','1'),('16','Portre-partitions','1'),('17','Lutrins','1'),('18','Guitares accoustiques','2'),('19','Guitares électriques','2'),('20','Batteries Accoustiques','4'),('21','Cymbales','4'),('22','Caisses claires','4'),('23','Appeaux','6'),('24','Boites à tonnerres','6'),('25','Carillons','6'),('26','Guitares','8'),('27','Mandolines','8'),('28','Ukulélé','8'),('29','Bois','9'),('30','Cuivres','9'),('31','Flutes à bec','9'),('32','Harmonica','9'),('33','Tam/Winds gongs','11'),('34','Percussions du monde','11'),('35','Percussions enfants','11'),('36','violons accessoires','12'),('37','Micros','13'),('38','Stands','13'),('39','Cables','13');

-- alimenter produits --
insert into produits (pro_ref,pro_lib,pro_desc,pro_unit_prix,pro_photo,pro_stock,pro_enligne,pro_rub_id,pro_four_id) 
values ("GAC56","Gold tone","Banjo Bluegrass à 5 cordes, avec housse
- Fût: Composite
- Anneau de tension: Métal lisse
- Repose-bras: Gold Tone gravé 
- Peau: LC Frosted 11",364,"jpg",5,1,18,7),
("GAC87","GEWA BALALAIKA 3","Banjo Bluegrass à 5 cordes, Prim-Balalaika, Diapason 440mm
Table massive en épicéa
Coque en Erable massif
Manche érable, Touche en bois dur, 19 frettes argentées
Plaque bois encastrée
",487,"jpg",2,1,18,9),
("BAT79","PEARL DRUMS","- Fûts 100% érable 6 plis/5,4 mm
- Coquilles NDL
- Cerclages emboutis acier 1,6 mm
- Système de suspensions OptiLoc
- Caisse claire bois 14 x 5,5” assortie
- Mini-muffler de grosse caisse
- Pack d'accessoires HWP-830 inclus : 1 x pédale Demonator P-930, 1 x stand cymbale mixte BC-830, 1x stand cymbale droit C-830, 1 x stand caisse claire S-830 et 1 x stand hi-hat H-830
- Livrée avec 2 supports de tom TH-900I
",1099,"jpg",3,1,20,17),

("BAT24","QUEST NATURAL","Finition laquée impeccable, fûts bouleau 6 plis, peaux Remo Ambassador UK, supports de tom à rotule, pack accessoires complet, la Quest s'offre tous les attributs d'une batterie de scène ou de studio sans vous en faire payer le prix"
,699,"jpg",0,0,20,11),
("IE104","ROAD HR400","Le cor d'harmonie double Eagletone ROAD HR400 est facile d'émission, juste, et présente des qualités mécaniques rares pour un instrument d'étude. Il s'adresse tout particulièrement au débutant qui souhaite s'initier au cor double.
",586,"jpg",3,1,9,13),
("IE145","ROAD FH100","Avec le bugle ROAD FH100, Eagletone propose aux débutants un instrument facile à jouer et juste pour une entrée en matière en toute sérénité.
Le trigger sur la 3e coulisse d'accord permet un réglage précis de l'intonation et les sons obtenus sont doux et ronds. D'une grande souplesse d'émission, le ROAD FH100 est idéal pour commencer l'apprentissage du bugle.
",699,"jpg",0,0,20,11),
("RD200","ROLAND RD","Équipé de deux générateurs de son indépendants, d'un clavier Premium et de contrôleurs évolués, le piano numérique de scène RD-2000 de Roland propose des performances sur scène et en studio sans équivalent. Mélangeant des technologies de piano haut de gamme avec des possibilités de contrôle étendues, cet instrument de nouvelle génération se pose en nouveau standard sur le marché des pianos de scène, et permet d'atteindre les plus hauts nivaux de créativité et d'inspiration.
",3459,"jpg",2,1,7,21),
("RD848","KORG C1 AIR BK","30 sons d'instruments superbement réalistes, la diffusion audio Bluetooth et l'enregistrement intégré, développeront la créativité à un niveau supérieur pour les joueurs de tous niveaux augmentant de manière significative leur plaisir musical. Conçu et fabriqué au Japon, le KORG C1 Air redéfinit le piano numérique.
",859,"jpg",4,1,7,24),
("AC157","GS30 STAND DE GUITARE","- Stand universel pour guitare et basse 
- Points de contact recouverts de mousse protectrice 
- Stabilité assuré par embase trépied avec tampons anti-dérapants
",15,"jpg",7,1,1,4),
("AC167","EAGLETONE CELPICK 12","Accessoire indispensable du guitariste, les médiators Eagletone sont disponibles en celluloid ou nylon de différents calibres et coloris. Bien finis, les extrémités polies permettent des attaques définies. Ils sont livrés par 12 ou 24 pièces panachées pour tester et trouver le médiator qui vous convient.
",5.99,"jpg",25,1,1,3),
("AC789","CP100 ASL","Le capodastre CP100 est léger et s'adapte parfaitement à la position sur le manche pour une justesse constante. Le patin d'appui en caoutchouc absorbe les vibrations parasites et préserve les cordes.
",9.50,"jpg",23,1,1,2),
("HO145","DELUXE 20 F","Conçue pour des guitaristes par des guitaristes, la gamme Eagletone DELUXE 20 compile toutes les qualités que nous avons appréciées dans les meilleures housses du marché. Les guitaristes et bassistes de l'équipe Eagletone ont tous apporté leur contribution à la réalisation d'une série idéale devant répondre à ces critères :
- Protection de l'instrument 
- Robustesse, durabilité
- Confort et facilité de transport 
- Fonctionnalité (poches, fermetures, accessoires) 
- Esthétique 
- Prix abordable 
",45,"jpg",4,1,15,6),
("HO657","DELUXE 30 CL","Conçue pour des guitaristes par des guitaristes, la gamme Eagletone DELUXE 30 compile toutes les qualités que nous avons appréciées dans les meilleures housses du marché. Les guitaristes et bassistes de l'équipe Eagletone ont tous apporté leur contribution à la réalisation d'une série idéale devant répondre à ces critères :
- Protection de l'instrument 
- Robustesse, durabilité
- Confort et facilité de transport 
- Fonctionnalité (poches, fermetures, accessoires) 
- Esthétique 
- Prix abordable ",59,"jpg",3,1,15,25),

("MIC56","AT2020 V","L’Audio Technica AT2020 apporte un nouveau standard de performances et de qualité chez les microphones de studio à condensateur à ce niveau de prix. Son diaphragme de faible masse est fabriqué sur mesure pour une réponse en fréquence étendue et une réponse dans les transitoires supérieure. Avec un bruit intrinsèque très faible, il est parfaitement adapté aux matériels d’enregistrements numériques actuels. Ce microphone offre une dynamique étendue et tient facilement des niveaux de pression acoustique élevés. Sa construction robuste est conçue pour durer pendant des années.
",69,"jpg",5,3,13,8),
("MIC22","RODE NT1","Le RØDE NT1 est un micro révolutionnaire à condensateur de 1”. Bien que le boîtier du nouvel NT1 se distingue à peine de celui du NT1-A, le micro lui-même a fait l’objet d’une refonte intégrale. Seule la grille a été reprise telle quelle. Avec le NT1, les ingénieurs RØDE ont voulu réaliser un mariage d’innovation et de tradition: la capsule a donc été entièrement revue. Derrière son nom de code HF6, elle est l’exemple parfait de la fusion opérée par RØDE entre un design artistique et des techniques de fabrication de pointe.
",86,"jpg",3,1,13,19),
("AMP21","AMPLI 562DJ","Entièrement repensés, les nouveaux amplis Rumble sont plus légers et plus puissants que jamais : avec davantage de mordant, ils n'en conservent pas moins l'esprit Fender classique. Avec un tout nouveau circuit d'overdrive commutable au pied et une gamme de voicings polyvalents contrôlés par trois boutons, auxquels s'ajoute un haut-parleur Eminence®, cet ampli délivre des sons puissants qui vous permettront de trouver le son juste en toute situation.
",99,"jpg",6,1,2,3),
("AME77","EKIDS DSJ100B","La batterie enfant Ekids DSJ100 a tout d'une grande, sauf les dimensions ! Adaptée aux enfants de 7 ans et moins pour l'apprentissage de la batterie et déclinée en quatre coloris, un kit complet parfait pour débuter.
",329,"jpg",2,1,5,15),
("AMP55","ORANGE AMPS OBC112","Équipé d'un Lavoce Neodynium 12'' de 400 Watts, l'OBC112 produit des graves bluffant en dépit de sa petite taille.",
359,"jpg",1,1,2,22),
("POR66","MU151 PUPITRE","Le pupitre orchestre MU151 dispose d'un large plateau à simple rebord pour garder vos partitions à portée des yeux. Son système de réglage vous permettra de régler la hauteur d'une seule main, tout en garantissant la stabilité du pupitre.",19,"jpg",1,1,16,9),


-- Alimenter commerciaux --
INSERT INTO `commerciaux` (`commerc_nom`,`commerc_prenom`) VALUES ("Leon","Cheryl"),("Bernard","Kathleen"),("Fleming","Lareina"),("Clements","Kiara"),("Guthrie","Lane"),("Baird","Wing"),("Olsen","Nichole"),("Chang","Thomas"),("Frye","Wang"),("Casey","Lacy");


-- Alimenter coefficient_client --
INSERT INTO `coefficient_client` (`coeff_prix`,`coeff_lib`) VALUES ("1.1","professionnel gros client"),("1.2","Professionnel bon client"),("1.3","Professionnel assez bon client"),("1.4","Particulier très bon client"),("1.5","Particulier client régulier"),("1.6","Particulier nouveau client");

-- Alimenter clients --

INSERT INTO `clients` (`cli_ref`,`cli_nom`,`cli_prenom`,`cli_adress`,`cli_postal`,`cli_ville`,`cli_mail`,`cli_phone`,`cli_pays_sig`,`cli_commerc_id`,`cli_coeff_prix`)
VALUES (`53702`,"Shafira","Vance","P.O. Box 350, 9578 Lectus St.","410551","Baardegem","Mauris.neque@noncursus.co.uk","0521777759","GB",3,1.6),
(`53703`,"Jamelia",NULL,"Ap #398-6608 Velit. Ave","90981","Vannes","scelerisque.mollis.Phasellus@Ut.fr","0340237899","FR",1,1.2),
(`53704`,"Claire","Eric","Ap #492-9566 Et Road","05081-42756","Deventer","Curabitur.ut.odio@tinciduntvehicularisus.org","0989048661","US",2,1.5),
(`53705`,"Alika","Jermaine","660-7974 Erat Av.","890512","Nampa","dolor.dolor@dignissimMaecenasornare.edu","0880051375","RU",5,1.6),
(`53706`,"Caesar Adena",NULL,"Ap #617-750 Amet, St.","134440","Enkhuizen","commodo.auctor@lobortisultricesVivamus.com","0440596425","AU",3,1.3),
(`53707`,"Keaton","Nadine","Ap #209-5721 At St.","46-982","San José del Guaviare","Nam.consequat@Morbi.ca","0787355025","CA",4,1.4),
(`53708`,"Kibo Germaine",NULL,"9280 Vitae St.","19842","Meerle","magnis.dis.parturient@suscipitest.com","0582805072","GR",1.2,1),
(`53709`,"Linda","Paul","503-646 Mauris Av.","44584","Bello","iaculis.quis.pede@vehiculaaliquetlibero.co.uk","0355625982","DE",5,1.6),
(`53710`,"Price Knox",NULL,"P.O. Box 499, 1381 Nunc St.","05462","Harnai","metus.vitae@dignissim.co.uk","0688937760","NL",6,1.1),
(`53711`,"Macaulay FLYNN",NULL,"142 At Road","82850","Termes","porttitor.vulputate.posuere@necanteMaecenas.ca","0753211076","CA",3,1.3);


INSERT INTO `clients` (`cli_ref`,`cli_nom`,`cli_prenom`,`cli_adress`,`cli_postal`,`cli_ville`,`cli_mail`,`cli_phone`,`cli_pays_sig`,`cli_commerc_id`,`cli_coeff_prix`) 
VALUES ("53603","Joan","Regan","P.O. Box 325, 1089 Dui.Rad","43515","Viggianello","ut.sem.Nulla@laciniaorci.org","0974035811","ES",6,1.4),
("53604","Wendy","Lani","2685 Feugiat. Ave","707891","Felitto","ipsum.Phasellus.vitae@mauris.net","0470305975","AR",8,1.6),
("53605","Quinn Kenyon",NULL,"P.O. Box 230, 9858 Nisl. Rd.","616899","Mumbai","lobortis@Nullamvelitdui.co.uk","0963234543","IT",9,1.3),
("53606","Amery PLATO",NULL,"2642 Ac Street","371414","San Ignacio","eu@utaliquamiaculis.edu","0293396739","HU",10,1.2),
("53607","Herrod","Yolanda","4269 Hendrerit St.","V9S 5B2","Erchie","placerat.Cras@acmetusvitae.ca","0108742269","TH",7,1.5),
("53608","Hanna","Jarrod","9965 Enim Ave","578111","Bothey","felis.purus@tristiquepellentesque.org","0534327176","CH",2,1.4),
("53609","Odysseus",NULL,"Ap #349-8205 Volutpat. Avenue","3829 BE","Orp-le-Grand","et.malesuada.fames@tincidunt.co.uk","0644121773","GB",1,1.1),
("53610","Justin","Louis","442-1792 Mollis Avenue","R9H 2C1","Bregenz","in.tempus@Proin.org","0779943092","US",9,1.6),
("53611","RinahMaite",NULL,"Ap #127-1882 Malesuada. Avenue","Z2071","Limoges","nunc.risus@velturpisAliquam.org","0278920485","AT",8,1.3),
("53612","Salvador","Sonia","5751 Netus Avenue","562116","Sant'Omero","non.lobortis@inceptos.org","0314865021",'RE',4,1.5);

INSERT INTO `clients` (`cli_ref`,`cli_nom`,`cli_prenom`,`cli_adress`,`cli_postal`,`cli_ville`,`cli_mail`,`cli_phone`,`cli_pays_sig`,`cli_commerc_id`,`cli_coeff_prix`) 
VALUES ("57603","DaiFleur",NULL,"702-3060 Est. Rd.","Z1898","Fauvillers","ligula@nislsemconsequat.org","0996787034","FR",10,1.1),
("57604","Hyacinth",NULL,"P.O. Box 404, 3710 Ornare. St.","Z3774","Abolens","suscipit.nonummy.Fusce@et.co.uk","0562641824","GB",9,1.2),
("57605","Perry","Melinda","798-3366 Id St.","K4C 7N4","Valleyview","erat@Nulla.ca","0593796816","CA",8,1.5),
("57606","Montana William",NULL,"Ap #269-9938 Vulputate Rd.","48262","Midnapore","est.vitae@Phasellusdolorelit.edu","0139864863","LU",7,1.3),
("57607","Flavia Xanthus",NULL,"340-4593 Ridiculus Ave","5711","Fort Smith","vitae.sodales@morbitristique.edu","0739751307","VE",6,1.2),
("57608","Omar","Joel","P.O. Box 593, 1102 Sed Street","51006","Sint-Gillis-bij-Dendermonde","Ut.sagittis@tellusSuspendissesed.co.uk","0683231380","SG",5,1.6),
("57609","Amos","Orson","218-6576 Vivamus Rd.","00648","Taldom","Fusce@Cumsociis.co.uk","0737776573","RO",4,1.6),
("57610","Veda","Barbara","P.O. Box 572, 7909 Rutrum St.","48994","San Vicente del Caguán","urna.Nullam.lobortis@bibendum.edu","0664760337","BE",3,1.5),
("57611","Danielle","Colin","P.O. Box 132, 7126 Lectus St.","1977","Chepén","Mauris@magnaSed.ca","0144372372","RU",2,1.4),
("57612","Macaulay","Carol","Ap #285-4595 Etiam Street","26771","San Vicente del Caguán","diam.Duis@et.net","0925713237","AR",1,1.6);



-- alimenter table client --

INSERT INTO `commande` (`com_ref`,`com_date`,`com_cli_ref`) 
VALUES (92350,"2020-10-10","57603"),
(92351,"2020-11-23","53612"),
(92352,"2020-10-09","57605"),
(92353,"2020-09-07","57612"),
(92354,"2020-10-11","57606"),
(92355,"2020-09-08","57604"),
(92356,"2020-10-19","57606"),
(92357,"2020-11-18","57603"),
(92358,"2020-09-20","53702"),
(92359,"2020-08-28","57612");
INSERT INTO `commande` (`com_ref`,`com_date`,`com_cli_ref`) 
VALUES (92360,"2020-09-16","57605"),
(92361,"2020-08-24","53612"),
(92362,"2020-10-13","57605"),
(92363,"2020-10-29","57603"),
(92364,"2020-10-19","53703"),
(92365,"2020-10-20","57612"),
(92366,"2020-10-15","57603"),
(92367,"2020-09-01","57605"),
(92368,"2020-09-11","57603"),
(92369,"2020-10-15","53612");
INSERT INTO `commande` (`com_ref`,`com_date`,`com_cli_ref`) 
VALUES (92370,"2020-09-04","53702"),
(92371,"2020-09-12","53706"),
(92372,"2020-10-22","57605"),
(92373,"2020-10-09","57606"),
(92374,"2020-10-25","53704"),
(92375,"2020-08-27","57612"),
(92376,"2020-11-08","53702"),
(92377,"2020-09-23","53702"),
(92378,"2020-09-05","57612"),
(92379,"2020-09-09","53705");


-- alimenter ligne de commande --

insert into `ligne_de_commande`(lign_cmd_id,lign_cmd_unitprix,lign_cmd_qtite,lign_cmd_pro_ref,lign_cmd_com_ref) 
values (1,86,1,"MIC22",92350),
(2,1099,1,"BAT79",92351),
(3,5.99,4,"AC167",92352),
(4,364,1,"GAC56",92352),
(5,586,1,"IE104",92353),
(6,487,1,"GAC87",92354),
(7,586,1,"IE104",92355),
(8,359,1,"AMP55",92355),
(9,15,1,"AC157",92356),
(10,5.99,1,"AC167",92357),
(11,9.50,2,"AC789",92357),
(12,59,1,"HO145",92357),
(13,59,1,"HO657",92358),
(14,86,1,"MIC22",92359),
(15,3459,1,"RD200",92360);


insert into `ligne_de_commande`(lign_cmd_id,lign_cmd_unitprix,lign_cmd_qtite,lign_cmd_pro_ref,lign_cmd_com_ref) 
values 
(16,86,1,"MIC22",92361),
(17,19,1,"POR66",92362),
(18,586,1,"IE108",92363),
(19,487,1,"GAC87",92364),
(20,5.99,1,"AC167",92365),
(21,86,1,"MIC22",92365),
(22,859,1,"RD848",92366),
(23,359,1,"AMP55",92367),
(24,699,1,"BAT24",92368),
(25,99,1,"AMP21",92369);

insert into `ligne_de_commande`(lign_cmd_id,lign_cmd_unitprix,lign_cmd_qtite,lign_cmd_pro_ref,lign_cmd_com_ref) 
values 
(26,859,1,"RD848",92370),
(27,329,1,"AME77",92371),
(28,19,1,"POR66",92372),
(29,59,1,"HO657",92373),
(30,699,1,"BAT24",92374),
(31,364,1,"GAC56",92375),
(32,5.99,2,"AC167",92375),
(33,69,1,"MIC56",92376),
(34,99,1,"AMP21",92377),
(35,699,1,"BAT24",92378),
(36,487,1,"GAC87",92379);

-- livraison --

INSERT INTO `livraison` (`livr_id`,`livr_adress`,`livr_date`,`livr_details`,`livr_status`) 
VALUES (1,"5751 Netus Avenue","2020-08-27",NULL,"livré"),
(2,"Ap #285-4595 Etiam Street","2020-08-29",NULL,"livré"),
(3,"Ap #285-4595 Etiam Street","2020-08-28",NULL,'livré'),
(4,"798-3366 Id St.","2020-09-04",NULL,'livré'),
(5,"P.O. Box 350, 9578 Lectus St.","2020-09-17","colis oublié sur les quais","livré"),
(6,"P.O. Box 350, 9578 Lectus St.","2020-09-08",null,"livré"),
(7,"P.O. Box 404, 3710 Ornare. St.","2020-09-10",null,"livré"),
(8,"P.O. Box 404, 3710 Ornare. St.","2020-09-10",null,"livré"),
(9,"660-7974 Erat Av.","2020-09-11",null,"livré"),
(10,"702-3060 Est. Rd.","2020-09-15",null,"livré");

INSERT INTO `livraison` (`livr_id`,`livr_adress`,`livr_date`,`livr_details`,`livr_status`) 
VALUES 
(11,"Ap #617-750 Amet, St","2020-09-15",null,"livré"),
(12,"798-3366 Id St.","2020-09-26","rupture de stock , livré en retard","livré"),
(13,"P.O. Box 350, 9578 Lectus St.","2020-09-25",null,"livré"),
(14,"P.O. Box 350, 9578 Lectus St.","2020-10-27",null ,"livré"),
(15,"798-3366 Id St.","2020-10-15",null,'livré'),
(16,"Ap #269-9938 Vulputate Rd.","2020-10-17",null,"livré"),
(17,"702-3060 Est. Rd.","2020-10-14",null,"livré"),
(18,"Ap #269-9938 Vulputate Rd","2020-10-14",null,"livré"),
(19,"798-3366 Id St.","2020-10-18",null,"livré"),
(20,"702-3060 Est. Rd.","2020-10-25","colis livré au mauvais destinataire.Retourné puis livré","livré");
INSERT INTO `livraison` (`livr_id`,`livr_adress`,`livr_date`,`livr_details`,`livr_status`) 
VALUES 
(21,"5751 Netus Avenue","2020-10-18",null,"livré"),
(22,"Ap #269-9938 Vulputate Rd.","2020-10-23",null,"livré"),
(23,"Ap #398-6608 Velit. Ave","2020-10-21",null,"livré"),
(24,"Ap #285-4595 Etiam Street","2020-10-21",null,"livré"),
(25,"798-3366 Id St.","2020-10-25",null,"livré"),
(26,"Ap #492-9566 Et Road","2020-10-30",null,"livré"),
(27,"702-3060 Est. Rd.","2020-10-31",null,"livré"),
(28,"P.O. Box 350, 9578 Lectus St.",null,"colis oublié","livraison en cours"),
(29,"702-3060 Est. Rd.","2020-11-20",null,"livré"),
(30,"5751 Netus Avenue",null,null,"non livré");



-- ligne de livraison --

INSERT INTO `ligne_de_livraison` (`lign_livr_id`,`lign_livr_lign_cmd_id`,`lign_livr_livr_id`) 
VALUES 
(1,16,1),
(2,31,2),
(3,32,2),
(4,14,3),
(5,23,4),
(6,26,5),
(7,35,6),
(8,5,7),
(9,7,8),
(10,8,8),
(11,36,9),
(12,24,10),
(13,27,11),
(14,15,12),
(15,13,13),
(16,34,14),
(17,3,15),
(18,4,15),
(19,29,16),
(20,1,17),
(21,6,18),
(22,17,19),
(23,25,20),
(24,22,21),
(25,9,22),
(26,19,23),
(27,20,24),
(28,21,24),
(29,28,25),
(30,30,26),
(31,18,27),
(32,33,28),
(33,10,29),
(34,11,29),
(35,12,29),
(36,2,30);

-- facture --
INSERT INTO `facture` (`fact_ref`,`fact_adress`,`fact_paym_date`,`fact_cmd_total`,`fact_date`,`fact_tot_discount`,`fact_tva`,`fact_coeff_prix`,`fact_com_ref`) 
VALUES 
("76524","5751 Netus Avenue","2020-08-24",86,"2020-08-24",null,20,1.5,"92361"),
("76525","Ap #285-4595 Etiam Street","2020-08-27",369.99,"2020-08-27",null,20,1.6,"92375"),
("76526","Ap #285-4595 Etiam Street","2020-08-28",86,"2020-08-28",10,20,1.6,"92359"),
("76527","798-3366 Id St.","2020-09-01",359,"2020-09-01",NULL,20,1.5,"92367"),
("76528","P.O. Box 350, 9578 Lectus St.","2020-09-04",859,"2020-09-04",null,20,1.6,"92370"),
("76529","Ap #285-4595 Etiam Street","2020-09-05",699,"2020-09-05",20,20,1.6,"92378"),
("76530","Ap #285-4595 Etiam Street","2020-09-07",586,"2020-09-07",20,20,1.6,"92353"),
("76531","P.O. Box 404, 3710 Ornare. St","2020-09-30",945,"2020-09-08",null,20,1.2,"92355"),
("76532","660-7974 Erat Av.","2020-09-09",487,"2020-09-09",null,20,1.6,"92379"),
("76533","702-3060 Est. Rd.","2020-09-30",699,"2020-09-11",NULL,20,1.1,"92368"),
("76534","Ap #617-750 Amet, St.","2020-09-30",329,"2020-09-12",null,20,1.3,"92371"),
("76535","798-3366 Id St.","2020-09-16",3459,"2020-09-16",null,20,1.5,"92360"),
("76536","P.O. Box 350, 9578 Lectus St.","2020-09-20",59,"2020-09-20",null,20,1.6,"92358"),
("76537","P.O. Box 350, 9578 Lectus St.","2020-09-23",99.00,"2020-09-23",null,20,1.6,"92377"),
("76538","798-3366 Id St.","2020-10-09",369.99,"2020-10-09",null,20,1.5,"92352"),
("76539","Ap #269-9938 Vulputate Rd.","2020-10-30",59.00,"2020-10-09",null,20,1.3,"92373"),
("76540","702-3060 Est. Rd.","2020-10-30",86.00,"2020-10-10",null,20,1.1,"92350"),
("76541","Ap #269-9938 Vulputate Rd.","2020-10-30",487.00,"2020-10-11",null,20,1.3,"92354"),
("76542","798-3366 Id St.","2020-10-13",19.00,"2020-10-13",null,20,1.5,"92362"),
("76543","702-3060 Est. Rd.","2020-10-30",859.00,"2020-10-15",null,20,1.1,"92366"),
("76544","5751 Netus Avenue","2020-10-15",99,"2020-10-15",null,20,1.5,"92369"),
("76545","Ap #269-9938 Vulputate Rd.","2020-10-30",15,"2020-10-19",null,20,1.3,"92356"),
("76546","Ap #398-6608 Velit. Ave","2020-10-30",487,"2020-10-19",null,20,1.2,"92364"),
("76547","Ap #285-4595 Etiam Street","2020-10-20",91.99,"2020-10-20",null,20,1.6,"92365"),
("76548","798-3366 Id St.","2020-10-22",19.00,"2020-10-22",null,20,1.5,"92372"),
("76549","Ap #492-9566 Et Road","2020-10-25",699.00,"2020-10-25",null,20,1.5,"92374"),
("76550","702-3060 Est. Rd.","2020-10-30",586.00,"2020-10-29",null,20,1.1,"92363"),
("76551","P.O. Box 350, 9578 Lectus St.","2020-11-08",69.00,"2020-11-08",null,20,1.6,"92376"),
("76552","702-3060 Est. Rd.","2020-11-30",74.50,"2020-11-18",null,20,1.1,"92357"),
("76553","5751 Netus Avenue","2020-11-23",1099.00,"2020-11-23",null,20,1.5,"92351");



