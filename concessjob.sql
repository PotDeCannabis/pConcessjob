INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_concess', 'Concessionaire', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_concess', 'Concessionaire', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_concess', 'Concessionaire', 1)
;

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('concess', 0, 'recrue', 'Recrue', 20, '', ''),
('concess', 1, 'novice', 'Novice', 30, '', ''),
('concess', 2, 'experimenter', 'Expérimenter', 40, '', ''),
('concess', 3, 'medecin_chef', "Chef de Magasin", 60, '', ''),
('concess', 4, 'boss', 'Directeur', 80, '', '');

INSERT INTO `jobs` (name, label) VALUES
	('concess','Concessionaire')
;

CREATE TABLE IF NOT EXISTS `owned_vehicles` (
	`owner` varchar(40) NOT NULL,
	`plate` varchar(12) NOT NULL,
	`vehicle` LONGTEXT DEFAULT NULL,
	`type` varchar(20) NOT NULL DEFAULT 'car',
	`stored` tinyint(1) NOT NULL DEFAULT 1,
	PRIMARY KEY (`plate`)
);

INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES 
('contract', 'Contrat de vente', '5', '0', '1');