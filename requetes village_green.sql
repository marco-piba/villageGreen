 -- 1.afficher le/les produits fournis par chaque fournisseur --
select  four_nom ,pro_ref,pro_lib,pro_desc,pro_unit_prix  from produits join fournisseurs on pro_four_id = four_id ; 

 -- 2.afficher la categorie et sous-categorie de chaque produit --
SELECT pro_ref,pro_lib ,rub_id,m.rub_nom  FROM rubriques join produits on pro_rub_id = rub_id;

-- 3.afficher la reference du produit , le libellé court et la description , le prix d'achat et la photo  --
SELECT pro_ref as `reference produit `,pro_lib as `produit` ,e.rub_nom as `rubriques`, m.rub_nom as `sous-rubriques` FROM produits left join rubriques e on e.rub_id = pro_rub_id left join rubriques m on e.rub_parent_id = m.rub_id group by pro_ref;

-- 4.afficher chaque produit avec son stock et si il est en ligne   --
SELECT pro_ref , pro_lib,pro_stock,pro_enligne FROM `produits`

-- 5.afficher le prix d'achat et le prix de vente de chaque produit dans chaque commande  --
SELECT com_ref ,lign_cmd_id,lign_cmd_pro_ref,lign_cmd_unitprix,lign_cmd_qtite, coeff_prix ,fact_tva,((lign_cmd_unitprix*lign_cmd_qtite*coeff_prix)*1.2) as `total à payer`FROM coefficient_client join clients on coeff_prix=cli_coeff_prix join commande on cli_ref=com_cli_ref join ligne_de_commande on com_ref=lign_cmd_com_ref left join facture on fact_com_ref =com_ref;

-- 6.afficher le commercial particulier de chaque client 
SELECT commerc_nom as `commercial particulier `, cli_ref as `reference du client` ,cli_nom as `nom du client`, cli_prenom as `prenom du client `,coeff_lib from commerciaux join clients on commerc_id = cli_commerc_id left join coefficient_client on coeff_prix = cli_coeff_prix;

-- 7.afficher le nom du client , sa commande , le prix total a payer (incluant le coeef client et la tva ) puis la montant de la réduction offerte (ou pas) par le commercial --
SELECT cli_ref,cli_nom,cli_prenom,com_ref, lign_cmd_id ,lign_cmd_pro_ref,lign_cmd_unitprix ,lign_cmd_qtite ,coeff_prix ,fact_tva,((lign_cmd_unitprix *lign_cmd_qtite*coeff_prix)*1.2) as `prix après taxe` ,fact_tot_discount from coefficient_client join clients on coeff_prix = cli_coeff_prix join commande on cli_ref =com_cli_ref join ligne_de_commande on com_ref = lign_cmd_com_ref left join facture on com_ref = fact_com_ref;

-- 8. afficher l'adresse de livraison et l'adresse de facturation de chaque commande  -- 
SELECT com_ref , fact_adress , livr_adress ,cli_adress from commande join facture on com_ref = fact_com_ref join ligne_de_commande on com_ref = lign_cmd_com_ref join ligne_de_livraison on lign_livr_lign_cmd_id = lign_cmd_id join livraison on lign_livr_livr_id =livr_id join clients on cli_ref =com_cli_ref group by com_ref;

-- 9. Afficher le coefficient du client , le libellé du coefficient ainsi que la date de paiement de chaque commande --
SELECT com_ref , cli_nom,cli_prenom,coeff_prix,coeff_lib ,fact_paym_date from coefficient_client join clients on cli_coeff_prix = coeff_prix join commande on cli_ref= com_cli_ref join facture on com_ref = fact_com_ref;

-- 10.afficher chaque commande avec les lignes de commandes ainsi que la date de livraison et le total facturer --
SELECT com_ref , lign_cmd_id , livr_status ,livr_date from commande join ligne_de_commande  on com_ref = lign_cmd_com_ref join ligne_de_livraison on lign_cmd_id =lign_livr_lign_cmd_id join livraison on livr_id = lign_livr_livr_id join facture on com_ref =fact_com_ref;

-- 11. Supprimer les commandes de plus de 3 ans.
DELETE from commande where com_ref = (select fact_com_ref from facture where YEAR(fact_date)< year(current_date())-3)


