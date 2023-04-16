INSERT INTO persona(cf,nome,cognome,indirizzo,telefono,email) VALUES 
('RSSMRA86L08G273B','Mario','Rossi','Via del Bon, 15, Udine','0432/557212','mario@rossi.email.it'),
('BNCMRA80B46L736S','Maria','Bianchi','Via non so, 32/a, Colugna','0432/439712',NULL),
('GNGSVN03R16D526P','Savino','Gangemi','Via E. Beauharnais, 75, Condino','0461/294042','s.gangemi@aruba.it'),
('NDRMLL77D50A485V','Mariella','Andreano','Via Mac Mahon, 210, Frontino','0721/753734','mariella.andreano@tele2.it'),
('RZGLSN70T14G338E','Alessandro','Arzaghi','Via Tre Castelli, 34/j, Ostiglia','0386/904253',NULL),
('DNPSCC46D03D151H','Isacco','Dinapoli','Via S.Senatore, 72, San Giusto','011/484777','idinapoli@yahoo.com'),
('LRCPIA46L41C266H','Pia','Lercaro','Via E.Panzacchi, 91/i, Casina','0522/395688','pia.lercaro@gmail.it'),
('STLLNA95L58I791Y','Alina','Astolfi','Passaggio Coperto delle Ore, Santa Maria Coghinas','079/959386','alina.astolfi@gmail.com'),
('MNTSBN92C17M201J','Sabino','Mantoan','Foro A.Vian, 253, Saint-Rhemy','0165/701399',NULL),
('MRGLGU06C48H811C','Lucia','Meriggi','Via I.Montenelli, 29/h, Vicopisano','050/425730','luigia.meriggi@hotmail.com'),
('MLNMRZ96T49G289S','Marzia','Molini','Largo Beatrice d''Este, 39, Rofrano','089/1060377',NULL);

INSERT INTO proprietario(cf,data_ultimo_pagamento,tasse_complessive) VALUES
('RSSMRA86L08G273B','2022-10-05',2524.14),
('DNPSCC46D03D151H','2022-11-13',6342.52),
('MRGLGU06C48H811C','2022-12-22',12423.01),
('MLNMRZ96T49G289S','2022-11-09',432.11);

INSERT INTO pilota(cf,numero_licenza) VALUES
('MLNMRZ96T49G289S',6436233),
('RZGLSN70T14G338E',6464667),
('MRGLGU06C48H811C',6423199),
('MNTSBN92C17M201J',6423145),
('NDRMLL77D50A485V',6435434);

INSERT INTO impiegato(cf,stipendio) VALUES
('BNCMRA80B46L736S',25000),
('GNGSVN03R16D526P',30000),
('LRCPIA46L41C266H',27000),
('STLLNA95L58I791Y',31000);

INSERT INTO hangar(numero,capacita,coord_x,coord_y,coord_z) VALUES
(1,4,12.4,35.2,3.1),
(2,3,2.4,10.2,3.5),
(3,5,20.4,50.2,2.9);

INSERT INTO modello(nome,peso,capacita) VALUES
('Hawker Hurricane',2476,1),
('Cirrus SR22',1009,5),
('Learjet 23',2790,8),
('Cessna 172',1111,4),
('Piper J-3 Cub',205,2),
('Lockheed Constellation',8301,95);

INSERT INTO aereo(numero_registrazione,nome_modello,cf_proprietario,numero_hangar) VALUES
(123412,'Hawker Hurricane','RSSMRA86L08G273B',1),
(212421,'Learjet 23','MLNMRZ96T49G289S',2),
(421451,'Piper J-3 Cub','MRGLGU06C48H811C',1),
(534555,'Cessna 172','DNPSCC46D03D151H',1),
(215221,'Cessna 172','DNPSCC46D03D151H',1),
(151351,'Cirrus SR22','DNPSCC46D03D151H',2),
(512542,'Lockheed Constellation','MLNMRZ96T49G289S',3);

INSERT INTO ha_volato_su(cf_pilota,numero_registrazione_aereo,ore) VALUES
('MLNMRZ96T49G289S',123412,10),
('MNTSBN92C17M201J',123412,5),
('MNTSBN92C17M201J',212421,11),
('MNTSBN92C17M201J',215221,43),
('MLNMRZ96T49G289S',421451,50),
('MLNMRZ96T49G289S',215221,31),
('RZGLSN70T14G338E',212421,12),
('MLNMRZ96T49G289S',534555,38),
('MNTSBN92C17M201J',512542,4),
('NDRMLL77D50A485V',534555,3),
('NDRMLL77D50A485V',512542,3);

INSERT INTO classe_intervento(codice,descrizione,tipo) VALUES
('1RIF','primo rifornimento','rifornimento'),
('RCOMP','rifornimento completo','rifornimento'),
('TAG','tagliando','manutenzione'),
('REV','revisione','manutenzione'),
('STR','manutenzione straordinaria','manutenzione'),
('PULINT','pulizia interna','pulizia'),
('PULEST','pulizia esterna','pulizia');	

INSERT INTO intervento(progressivo,numero_registrazione_aereo,codice_classe_intervento,data,durata) VALUES
(1,123412,'1RIF','2022-01-03',30),
(2,123412,'TAG','2022-02-14',500),
(3,123412,'RCOMP','2022-02-20',20),
(4,123412,'RCOMP','2022-03-01',20),
(1,512542,'PULINT','2022-02-15',60),
(2,512542,'PULEST','2022-03-30',60),
(1,421451,'RCOMP','2022-05-07',45),
(2,421451,'RCOMP','2022-05-12',45),
(3,421451,'RCOMP','2022-07-22',45),
(4,421451,'REV','2022-09-30',600),
(5,421451,'STR','2022-11-12',400),
(1,151351,'1RIF','2022-10-15',40),
(2,151351,'TAG','2022-11-01',800),
(1,534555,'PULINT','2022-03-23',75),
(2,534555,'PULEST','2022-04-07',75),
(3,534555,'TAG','2022-05-01',700),
(4,534555,'RCOMP','2022-10-17',30),
(5,534555,'RCOMP','2022-12-12',30);	

INSERT INTO puo_svolgere(cf_impiegato,nome_modello,codice_classe_intervento) VALUES
('BNCMRA80B46L736S','Hawker Hurricane','1RIF'),
('BNCMRA80B46L736S','Hawker Hurricane','TAG'),
('BNCMRA80B46L736S','Hawker Hurricane','RCOMP'),
('BNCMRA80B46L736S','Hawker Hurricane','REV'),
('GNGSVN03R16D526P','Lockheed Constellation','PULINT'),
('GNGSVN03R16D526P','Lockheed Constellation','PULEST'),
('GNGSVN03R16D526P','Piper J-3 Cub','RCOMP'),
('GNGSVN03R16D526P','Piper J-3 Cub','REV'),
('GNGSVN03R16D526P','Piper J-3 Cub','STR'),
('LRCPIA46L41C266H','Cirrus SR22','1RIF'),
('LRCPIA46L41C266H','Cirrus SR22','TAG'),
('STLLNA95L58I791Y','Cessna 172','PULINT'),
('STLLNA95L58I791Y','Cessna 172','PULEST'),
('STLLNA95L58I791Y','Cessna 172','TAG'),
('STLLNA95L58I791Y','Cessna 172','RCOMP'),
('STLLNA95L58I791Y','Hawker Hurricane','1RIF'),
('STLLNA95L58I791Y','Hawker Hurricane','TAG'),
('STLLNA95L58I791Y','Hawker Hurricane','RCOMP'),
('STLLNA95L58I791Y','Hawker Hurricane','REV');	

INSERT INTO ha_svolto(cf_impiegato,progressivo_intervento,numero_registrazione_aereo) VALUES
('BNCMRA80B46L736S',1,123412),
('BNCMRA80B46L736S',2,123412),
('BNCMRA80B46L736S',3,123412),
('BNCMRA80B46L736S',4,123412),
('STLLNA95L58I791Y',3,123412),
('STLLNA95L58I791Y',4,123412),
('GNGSVN03R16D526P',1,512542),
('GNGSVN03R16D526P',2,512542),
('GNGSVN03R16D526P',1,421451),
('GNGSVN03R16D526P',2,421451),
('GNGSVN03R16D526P',3,421451),
('GNGSVN03R16D526P',4,421451),
('GNGSVN03R16D526P',5,421451),
('LRCPIA46L41C266H',1,151351),
('LRCPIA46L41C266H',2,151351),
('STLLNA95L58I791Y',1,534555),
('STLLNA95L58I791Y',2,534555),
('STLLNA95L58I791Y',3,534555),
('STLLNA95L58I791Y',4,534555),
('STLLNA95L58I791Y',5,534555);		

