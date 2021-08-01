USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_mechanic', 'mechanic', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_mechanic', 'mechanic', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_mechanic', 'mechanic', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'mechanic')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'stagiaire','Stagiaire',20,'{}','{}'),
	('mechanic',1,'employer','Employer',40,'{}','{}'),
	('mechanic',2,'chef','Gérant Atelier',60,'{}','{}'),
	('mechanic',3,'coboss','Co Patron',85,'{}','{}'),
	('mechanic',4,'boss','Patron',100,'{}','{}')
;


