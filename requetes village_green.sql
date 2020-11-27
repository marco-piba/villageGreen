 -- 1.afficher le/les produits fournis par chaque fournisseur --
select  four_nom ,pro_ref,pro_lib,pro_desc,pro_unit_prix  from produits join fournisseurs on pro_four_id = four_id ; 

 -- 2.afficher la categorie et sous-categorie de chaque produit --
SELECT pro_ref,pro_lib ,e.rub_id,m.rub_nom FROM rubriques e left join rubriques m on m.rub_id= e.rub_parent_id join produits on pro_rub_id = e.rub_id

-- 3.afficher la reference du produit , le libellé court et la description , le prix d'achat et la photo  --
SELECT pro_ref as `reference produit `,pro_lib as `produit` , pro_desc as `description` ,pro_unit_prix as `prix d'achat` ,pro_photo from produits;

-- 4.afficher chaque produit avec son stock et si il est en ligne   --
SELECT pro_ref , pro_lib,pro_stock,pro_enligne FROM `produits`

-- 5.afficher le prix d'achat et le prix de vente de chaque produit dans chaque commande  --
SELECT com_ref ,lign_cmd_id,lign_cmd_pro_ref,lign_cmd_unitprix,lign_cmd_qtite, cli_coeff_prix ,com_tva,((lign_cmd_unitprix*lign_cmd_qtite*cli_coeff_prix)*1.2) as `total à payer` FROM clients join commande on cli_ref=com_cli_ref join ligne_de_commande on com_ref=lign_cmd_com_ref;

-- 6.afficher le commercial particulier de chaque client 
SELECT commerc_nom as `commercial particulier `, cli_ref as `reference du client` ,cli_nom as `nom du client`, cli_prenom as `prenom du client `,cli_coeff_lib from commerciaux join clients on commerc_id = cli_commerc_id ;

-- 7.afficher le nom du client , sa commande , le prix total a payer (incluant le coeff client et la tva ) puis le montant de la réduction offerte (ou pas) par le commercial --
SELECT cli_ref,cli_nom,cli_prenom,com_ref ,cli_coeff_prix ,com_tva,(select sum((lign_cmd_unitprix *lign_cmd_qtite*cli_coeff_prix)*1.2) as `prixTot` group by com_ref ) as `prix après taxe` ,com_tot_discount from clients join commande on cli_ref =com_cli_ref join ligne_de_commande on com_ref = lign_cmd_com_ref group by com_ref ;

-- 8. afficher l'adresse de livraison et l'adresse de facturation de chaque commande  -- 
SELECT com_ref , com_fact_adress , livr_adress ,cli_adress from commande join ligne_de_commande on com_ref = lign_cmd_com_ref join ligne_de_livraison on lign_livr_lign_cmd_id = lign_cmd_id join livraison on lign_livr_livr_id =livr_id join clients on cli_ref =com_cli_ref group by com_ref;

-- 9. Afficher le coefficient du client , le libellé du coefficient ainsi que la date de paiement de chaque commande --
SELECT com_ref , cli_nom,cli_prenom,cli_coeff_prix,cli_coeff_lib ,com_paym_date from clients join commande on cli_ref= com_cli_ref  
ORDER BY `clients`.`cli_coeff_prix` ASC;

-- 10.afficher chaque commande  avec la date et le status  de la livraison--
SELECT com_ref , livr_status ,livr_date from commande join ligne_de_commande on com_ref = lign_cmd_com_ref join ligne_de_livraison on lign_cmd_id =lign_livr_lign_cmd_id join livraison on livr_id = lign_livr_livr_id ORDER BY `livraison`.`livr_status` ASC

-- 11. Supprimer les commandes de plus de 3 ans.
DELETE from commande where com_ref = (select fact_com_ref from facture where YEAR(fact_date)< year(current_date())-3)

3.1.3 - chiffre d'affaires hors taxes généré pour l'ensemble et par fournisseur
SELECT four_nom, sum((lign_cmd_qtite*lign_cmd_unitprix*cli_coeff_prix)-(lign_cmd_qtite*lign_cmd_unitprix)-com_tot_discount) as CA par fournisseurs`,(select sum(((com_prix_total*cli_coeff_prix)-com_prix_total)-com_tot_discount) as `profit hors taxe d'une commande` FROM commande join clients on cli_ref = com_cli_ref )as `CA TOTAL`FROM fournisseurs join produits on four_id=pro_four_id join ligne_de_commande on pro_ref = lign_cmd_pro_ref join commande on lign_cmd_com_ref = com_ref join clients on cli_ref = com_cli_ref group by four_id

3.1.4 - liste des produits commandés pour une année sélectionnée (référence et nom du produit, quantité commandée, fournisseur)
select pro_ref as `ref produit` ,pro_lib as `produit libellé` ,four_nom as `nom fournisseur`, sum(lign_cmd_qtite) as `quantité` from fournisseurs JOIN produits on four_id = pro_four_id join ligne_de_commande on pro_ref = lign_cmd_pro_ref join commande on lign_cmd_com_ref =com_ref where YEAR(com_date) = YEAR(CURRENT_DATE()) group by pro_ref

3.1.5 - liste des commandes pour un client (date de commande, référence client, montant, état de la commande)
select cli_ref ,cli_nom ,cli_prenom, com_ref , (((com_prix_total*cli_coeff_prix)*1.2)-com_tot_discount) as `prix facturer` from clients join commande on cli_ref =com_cli_ref join ligne_de_commande on lign_cmd_com_ref =com_ref join ligne_de_livraison on lign_cmd_id = lign_livr_lign_cmd_id join livraison on lign_livr_livr_id =livr_id where cli_nom ='daiFleur'

3.1.6 - répartition du chiffre d'affaires hors taxes par type de client

3.1.7 - lister les commandes en cours de livraison.




