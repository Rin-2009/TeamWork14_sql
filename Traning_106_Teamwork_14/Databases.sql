-- ================================================================================
     --               MARKETPLACE DATABASE PROJECT
-- ================================================================================





-- ================================================================================
 --                        DATABASE 1
-- ================================================================================



/*banking system DB */

CREATE DATABASE banking_system;

USE banking_system;


/* table branches */

CREATE TABLE branches(
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    opened_at DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    
    CHECK (status IN ('active', 'inactive'))
);


/* table customers */

CREATE TABLE customers(
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_number VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    national_id VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100),
    phone VARCHAR(20),
    birthday DATE,
    city VARCHAR(100),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    
    CHECK(status IN ('active', 'inactive', 'blocked'))
);


/* table accounts */

CREATE TABLE accounts(
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type VARCHAR(25),
    currency VARCHAR(3) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0,
    opened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    
    CHECK (account_type IN ('checking', 'saving', 'business')),
    CHECK (currency IN ('SAR', 'USD', 'EUR', 'BRL')),
    CHECK (balance >= 0),
    CHECK (status IN ('active', 'frozen', 'closed'))
);


/* table beneficiaries */

CREATE TABLE beneficiaries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    beneficiary_account_id INT NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (beneficiary_account_id) REFERENCES accounts(id),

    CHECK (status IN ('active', 'inactive'))
);


/* table transfers */

CREATE TABLE transfers(
    id INT PRIMARY KEY AUTO_INCREMENT,
    reference_number VARCHAR(50) NOT NULL UNIQUE,
    from_account_id INT NOT NULL,
    to_account_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transfer_fee DECIMAL(15,2) DEFAULT 0,
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    status VARCHAR(20) DEFAULT 'pending',
    
    FOREIGN KEY (from_account_id) REFERENCES accounts(id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(id),
    
    CHECK (amount > 0),
    CHECK (transfer_fee >= 0),
    CHECK (from_account_id <> to_account_id),
    CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled'))
    
);


/* ================================================================================== */

/* table transactions */

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transfer_id INT,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_before DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed',
    
    FOREIGN KEY (account_id) REFERENCES accounts(id),
    FOREIGN KEY (transfer_id) REFERENCES transfers(id),
    
    CHECK (amount > 0),
    CHECK (transaction_type IN (
        'deposit',
        'withdrawal',
        'transfer_in',
        'transfer_out',
        'fee',
        'refund',
        'loan_payment'
    ))
);


/* TABLE cards */

CREATE TABLE cards (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    card_number VARCHAR(30) NOT NULL UNIQUE,
    card_type VARCHAR(20) NOT NULL,
    issued_at DATE NOT NULL,
    expiry_date DATE NOT NULL,
    daily_limit DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',

    FOREIGN KEY (account_id) REFERENCES accounts(id),

    CHECK (card_type IN ('debit', 'credit')),
    CHECK (daily_limit >= 0),

    CHECK (status IN (
        'active',
        'blocked',
        'expired',
        'cancelled'
    ))
);


/* TABLE card_transactions */

CREATE TABLE card_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    card_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    merchant_name VARCHAR(150) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    
    FOREIGN KEY (card_id) REFERENCES cards(id),
    
    CHECK (amount > 0),
    CHECK (status IN (
        'pending',
        'approved',
        'declined',
        'refunded'
    ))
);


/* table loan */

CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    loan_number VARCHAR(50) NOT NULL UNIQUE,
    principal_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',

    FOREIGN KEY (customer_id) REFERENCES customers(id),

    CHECK (principal_amount >= 0),
    CHECK (interest_rate >= 0),
    CHECK (total_amount >= principal_amount),
    CHECK (
        status IN (
            'pending',
            'active',
            'paid',
            'defaulted',
            'cancelled'
        )
    )
);


/* TABLE loan_installments */

CREATE TABLE loan_installments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    installment_number INT NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    paid_at DATETIME,
    status VARCHAR(20) DEFAULT 'pending',

    FOREIGN KEY (loan_id) REFERENCES loans(id),

    CHECK (amount >= 0),
    CHECK (paid_amount >= 0),
    CHECK (paid_amount <= amount),
    CHECK (
        status IN (
            'pending',
            'partially_paid',
            'paid',
            'overdue'
        )
    ),

    UNIQUE (loan_id, installment_number)
);


/* audit_logs */

CREATE TABLE audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    account_id INT,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);


-- inserting DATA to the banking system

-- =========================================
-- BRANCHES (6)
-- =========================================

INSERT INTO branches
(branch_code, branch_name, city, address, phone, opened_at, status)
VALUES
('BR001','Main Branch','Riyadh','King Fahd Road','0111111111','2020-01-01','active'),
('BR002','North Branch','Jeddah','King Road','0122222222','2020-02-01','active'),
('BR003','East Branch','Dammam','Main Street','0133333333','2020-03-01','active'),
('BR004','West Branch','Makkah','Central Road','0124444444','2020-04-01','active'),
('BR005','South Branch','Khobar','King Faisal Road','0135555555','2020-05-01','active'),
('BR006','Central Branch','Riyadh','Olaya Street','0116666666','2020-06-01','inactive');


-- =========================================
-- CUSTOMERS (50)
-- =========================================

INSERT INTO customers
(customer_number, full_name, national_id, email, phone,
 birthday, city, address, status)
VALUES
('C001','Ahmed Ali','N1001','ahmed01@email.com','0500000001','1990-01-10','Riyadh','Olaya','active'),
('C002','Mohammed Hassan','N1002','mohammed02@email.com','0500000002','1991-02-15','Jeddah','Al Hamra','active'),
('C003','Omar Khaled','N1003','omar03@email.com','0500000003','1988-03-20','Dammam','Al Shati','active'),
('C004','Sara Ahmed','N1004','sara04@email.com','0500000004','1995-04-25','Riyadh','Malaz','active'),
('C005','Noura Ali','N1005','noura05@email.com','0500000005','1993-05-30','Makkah','Aziziyah','active'),
('C006','Khalid Salem','N1006','khalid06@email.com','0500000006','1987-06-12','Khobar','Al Aqrabiyah','active'),
('C007','Fahad Omar','N1007','fahad07@email.com','0500000007','1992-07-18','Riyadh','Yasmin','active'),
('C008','Lama Hassan','N1008','lama08@email.com','0500000008','1994-08-22','Jeddah','Al Rawdah','active'),
('C009','Abdullah Saad','N1009','abdullah09@email.com','0500000009','1989-09-14','Dammam','Faisaliyah','active'),
('C010','Reem Khaled','N1010','reem10@email.com','0500000010','1996-10-05','Khobar','Al Ulaya','active'),

('C011','Yousef Ahmed','N1011','yousef11@email.com','0500000011','1986-11-19','Riyadh','Wurud','active'),
('C012','Huda Mohammed','N1012','huda12@email.com','0500000012','1991-12-08','Makkah','Aziziyah','active'),
('C013','Saad Ibrahim','N1013','saad13@email.com','0500000013','1985-01-27','Jeddah','Al Zahra','active'),
('C014','Maha Salem','N1014','maha14@email.com','0500000014','1993-02-11','Riyadh','Mursalat','active'),
('C015','Turki Nasser','N1015','turki15@email.com','0500000015','1990-03-17','Dammam','Shati','active'),
('C016','Rania Omar','N1016','rania16@email.com','0500000016','1995-04-29','Khobar','Bandariyah','active'),
('C017','Majed Hassan','N1017','majed17@email.com','0500000017','1988-05-13','Riyadh','Nakheel','active'),
('C018','Abeer Khaled','N1018','abeer18@email.com','0500000018','1992-06-21','Jeddah','Salamah','active'),
('C019','Nawaf Ahmed','N1019','nawaf19@email.com','0500000019','1987-07-09','Dammam','Nur','active'),
('C020','Dania Saad','N1020','dania20@email.com','0500000020','1994-08-16','Khobar','Hamra','active'),

('C021','Hassan Ali','N1021','hassan21@email.com','0500000021','1985-09-24','Riyadh','Batha','active'),
('C022','Nasser Mohammed','N1022','nasser22@email.com','0500000022','1990-10-12','Jeddah','Safa','active'),
('C023','Sultan Omar','N1023','sultan23@email.com','0500000023','1989-11-03','Dammam','Nur','active'),
('C024','Waleed Ibrahim','N1024','waleed24@email.com','0500000024','1993-12-15','Khobar','Aqrabiyah','active'),
('C025','Bader Salem','N1025','bader25@email.com','0500000025','1986-01-06','Riyadh','Rawdah','active'),
('C026','Faisal Saad','N1026','faisal26@email.com','0500000026','1991-02-28','Makkah','Misfalah','active'),
('C027','Rakan Nasser','N1027','rakan27@email.com','0500000027','1988-03-19','Riyadh','Hamra','active'),
('C028','Ziyad Majed','N1028','ziyad28@email.com','0500000028','1994-04-07','Jeddah','Marwah','active'),
('C029','Adel Ahmed','N1029','adel29@email.com','0500000029','1987-05-23','Dammam','Adamah','active'),
('C030','Yasser Saleh','N1030','yasser30@email.com','0500000030','1992-06-30','Khobar','Aqrabiyah','active'),

('C031','Mansour Mohammed','N1031','mansour31@email.com','0500000031','1986-07-14','Riyadh','Malaz','active'),
('C032','Ibrahim Ahmed','N1032','ibrahim32@email.com','0500000032','1990-08-26','Jeddah','Rawdah','active'),
('C033','Abdulrahman Khalid','N1033','abdulrahman33@email.com','0500000033','1988-09-05','Dammam','Shati','active'),
('C034','Meshari Omar','N1034','meshari34@email.com','0500000034','1993-10-18','Riyadh','Yasmin','active'),
('C035','Talal Hassan','N1035','talal35@email.com','0500000035','1987-11-29','Makkah','Aziziyah','active'),
('C036','Khalifa Salem','N1036','khalifa36@email.com','0500000036','1991-12-20','Khobar','Ulaya','active'),
('C037','Nasser Saad','N1037','nasser37@email.com','0500000037','1989-01-15','Jeddah','Hamra','active'),
('C038','Rami Nasser','N1038','rami38@email.com','0500000038','1994-02-09','Riyadh','Nakheel','active'),
('C039','Ayman Majed','N1039','ayman39@email.com','0500000039','1985-03-27','Dammam','Faisaliyah','active'),
('C040','Hatem Turki','N1040','hatem40@email.com','0500000040','1992-04-13','Khobar','Bandariyah','active'),

('C041','Khaled Abdullah','N1041','khaled41@email.com','0500000041','1988-05-21','Riyadh','Wurud','active'),
('C042','Amal Ali','N1042','amal42@email.com','0500000042','1990-06-08','Jeddah','Salamah','active'),
('C043','Mariam Hassan','N1043','mariam43@email.com','0500000043','1986-07-17','Dammam','Shati','active'),
('C044','Noor Ibrahim','N1044','noor44@email.com','0500000044','1993-08-25','Khobar','Aqrabiyah','active'),
('C045','Wijdan Salem','N1045','wijdan45@email.com','0500000045','1989-09-12','Riyadh','Olaya','active'),
('C046','Saeed Saad','N1046','saeed46@email.com','0500000046','1991-10-29','Makkah','Misfalah','active'),
('C047','Hind Nasser','N1047','hind47@email.com','0500000047','1995-11-06','Jeddah','Zahra','active'),
('C048','Faisal Majed','N1048','faisal48@email.com','0500000048','1987-12-22','Riyadh','Yasmin','active'),
('C049','Latifa Ahmed','N1049','latifa49@email.com','0500000049','1993-01-31','Dammam','Nur','inactive'),
('C050','Bandar Saleh','N1050','bandar50@email.com','0500000050','1985-02-18','Khobar','Khobar North','blocked');



/* two */

-- =========================================
-- ACCOUNTS (75)
-- =========================================

INSERT INTO accounts
(account_number, customer_id, branch_id, account_type, currency, balance, status)
VALUES
('A001',1,1,'checking','SAR',12500.00,'active'),
('A002',1,1,'saving','SAR',45000.00,'active'),
('A003',2,2,'checking','SAR',8200.00,'active'),
('A004',2,2,'saving','USD',12000.00,'active'),
('A005',3,3,'checking','SAR',15600.00,'active'),
('A006',3,3,'saving','EUR',9500.00,'active'),
('A007',4,1,'checking','SAR',23000.00,'active'),
('A008',5,1,'saving','SAR',67000.00,'active'),
('A009',5,1,'business','SAR',150000.00,'active'),
('A010',6,4,'checking','SAR',9100.00,'active'),

('A011',7,1,'checking','USD',7800.00,'active'),
('A012',8,2,'saving','SAR',34000.00,'active'),
('A013',9,3,'checking','EUR',5400.00,'active'),
('A014',10,5,'checking','SAR',18700.00,'active'),
('A015',11,1,'saving','SAR',29000.00,'active'),
('A016',12,4,'checking','SAR',11300.00,'active'),
('A017',13,3,'saving','USD',15600.00,'active'),
('A018',14,1,'checking','SAR',7200.00,'active'),
('A019',15,4,'saving','EUR',8700.00,'active'),
('A020',16,5,'checking','SAR',19200.00,'active'),

('A021',17,2,'checking','SAR',8100.00,'active'),
('A022',18,1,'saving','SAR',41000.00,'active'),
('A023',19,3,'checking','USD',6700.00,'active'),
('A024',20,5,'saving','SAR',53000.00,'active'),
('A025',21,1,'business','SAR',185000.00,'active'),
('A026',22,2,'checking','SAR',9300.00,'active'),
('A027',23,3,'saving','EUR',11400.00,'active'),
('A028',24,5,'checking','SAR',16100.00,'active'),
('A029',25,1,'saving','SAR',49000.00,'active'),
('A030',26,4,'checking','SAR',7600.00,'active'),

('A031',27,1,'checking','USD',8900.00,'active'),
('A032',28,2,'saving','SAR',37000.00,'active'),
('A033',29,3,'checking','SAR',12800.00,'active'),
('A034',30,5,'saving','EUR',10200.00,'active'),
('A035',31,1,'checking','SAR',21700.00,'active'),
('A036',32,2,'saving','SAR',61000.00,'active'),
('A037',33,3,'business','SAR',220000.00,'active'),
('A038',34,1,'checking','SAR',6800.00,'active'),
('A039',35,4,'saving','USD',13800.00,'active'),
('A040',36,5,'checking','SAR',17400.00,'active'),

('A041',37,2,'saving','SAR',33000.00,'active'),
('A042',38,1,'checking','EUR',7600.00,'active'),
('A043',39,3,'saving','SAR',45000.00,'active'),
('A044',40,5,'checking','SAR',9900.00,'active'),
('A045',41,1,'business','SAR',175000.00,'active'),
('A046',42,2,'checking','SAR',14300.00,'active'),
('A047',43,3,'saving','USD',9200.00,'active'),
('A048',44,5,'checking','SAR',18400.00,'active'),
('A049',45,1,'saving','SAR',56000.00,'active'),
('A050',46,4,'checking','SAR',8100.00,'active'),

('A051',47,2,'saving','EUR',11500.00,'active'),
('A052',48,1,'checking','SAR',13200.00,'active'),
('A053',49,3,'saving','SAR',39000.00,'active'),
('A054',50,5,'checking','SAR',4500.00,'frozen'),
('A055',7,1,'saving','SAR',27000.00,'active'),
('A056',12,2,'checking','USD',6500.00,'active'),
('A057',18,1,'saving','EUR',8700.00,'active'),
('A058',23,3,'checking','SAR',11900.00,'active'),
('A059',29,3,'saving','SAR',31000.00,'active'),
('A060',35,4,'checking','SAR',8700.00,'active'),

('A061',41,1,'saving','USD',14400.00,'active'),
('A062',46,4,'checking','SAR',10200.00,'active'),
('A063',2,2,'business','SAR',98000.00,'active'),
('A064',8,2,'checking','SAR',7600.00,'active'),
('A065',14,1,'saving','SAR',28500.00,'active'),
('A066',20,5,'checking','USD',7100.00,'active'),
('A067',26,4,'saving','SAR',36000.00,'active'),
('A068',32,2,'checking','EUR',6800.00,'active'),
('A069',38,1,'saving','SAR',42000.00,'active'),
('A070',44,5,'checking','SAR',9300.00,'active'),

('A071',10,5,'saving','USD',12000.00,'active'),
('A072',16,5,'checking','SAR',15500.00,'active'),
('A073',22,2,'saving','SAR',47000.00,'active'),
('A074',28,2,'checking','SAR',8200.00,'active'),
('A075',34,1,'saving','EUR',9700.00,'active');


-- =========================================
-- BENEFICIARIES (40)
-- =========================================

INSERT INTO beneficiaries
(customer_id, beneficiary_account_id, nickname, status)
VALUES
(1,3,'Mohammed Account','active'),
(1,5,'Omar Account','active'),
(2,1,'Ahmed Account','active'),
(2,7,'Khalid Account','active'),
(3,8,'Fahad Account','active'),
(3,10,'Abdullah Account','active'),
(4,12,'Yousef Account','active'),
(4,15,'Sara Account','active'),
(5,16,'Noura Account','active'),
(5,18,'Huda Account','active'),

(6,20,'Maha Account','active'),
(7,22,'Abeer Account','active'),
(8,24,'Asma Account','active'),
(9,25,'Business Account','active'),
(10,27,'Ziyad Account','active'),
(11,28,'Waleed Account','active'),
(12,29,'Bader Account','active'),
(13,30,'Faisal Account','active'),
(14,31,'Rakan Account','active'),
(15,32,'Majed Account','active'),

(16,33,'Adel Account','active'),
(17,34,'Yasser Account','active'),
(18,35,'Mansour Account','active'),
(19,36,'Ibrahim Account','active'),
(20,37,'Abdulrahman Account','active'),
(21,38,'Meshari Account','active'),
(22,39,'Talal Account','active'),
(23,40,'Khalifa Account','active'),
(24,41,'Nasser Account','active'),
(25,42,'Rami Account','active'),

(26,43,'Ayman Account','active'),
(27,44,'Hatem Account','active'),
(28,45,'Business Savings','active'),
(29,46,'Saeed Account','active'),
(30,47,'Faisal Account','active'),
(31,48,'Latifa Account','active'),
(32,49,'Wijdan Account','active'),
(33,50,'Hind Account','inactive'),
(34,51,'Faisal Account','active'),
(35,52,'Ahmed Account','active');



/* three */

-- =========================================
-- TRANSFERS (150)
-- =========================================

INSERT INTO transfers
(reference_number, from_account_id, to_account_id, amount, transfer_fee,
 description, created_at, completed_at, status)
VALUES
('TR001',1,3,500.00,5.00,'Family transfer','2024-01-01 09:00:00','2024-01-01 09:05:00','completed'),
('TR002',2,4,1000.00,10.00,'Monthly payment','2024-01-02 10:00:00','2024-01-02 10:05:00','completed'),
('TR003',3,5,750.00,5.00,'Personal transfer','2024-01-03 11:00:00',NULL,'pending'),
('TR004',4,7,1200.00,10.00,'Bill payment','2024-01-04 12:00:00',NULL,'failed'),
('TR005',5,8,850.00,5.00,'Family support','2024-01-05 13:00:00','2024-01-05 13:05:00','completed'),
('TR006',6,10,1500.00,10.00,'Rent payment','2024-01-06 09:30:00','2024-01-06 09:35:00','completed'),
('TR007',7,12,400.00,5.00,'Personal transfer','2024-01-07 10:30:00',NULL,'processing'),
('TR008',8,15,2300.00,10.00,'Family transfer','2024-01-08 11:30:00','2024-01-08 11:35:00','completed'),
('TR009',9,16,1800.00,5.00,'Business payment','2024-01-09 12:30:00',NULL,'pending'),
('TR010',10,18,600.00,5.00,'Personal transfer','2024-01-10 13:30:00',NULL,'cancelled'),

('TR011',11,20,950.00,5.00,'Family transfer','2024-01-11 09:00:00','2024-01-11 09:05:00','completed'),
('TR012',12,22,1100.00,10.00,'Monthly payment','2024-01-12 10:00:00','2024-01-12 10:05:00','completed'),
('TR013',13,24,700.00,5.00,'Personal transfer','2024-01-13 11:00:00','2024-01-13 11:05:00','completed'),
('TR014',14,25,2500.00,15.00,'Business payment','2024-01-14 12:00:00',NULL,'processing'),
('TR015',15,27,900.00,5.00,'Family support','2024-01-15 13:00:00',NULL,'pending'),
('TR016',16,28,1300.00,10.00,'Bill payment','2024-01-16 09:00:00','2024-01-16 09:05:00','completed'),
('TR017',17,30,650.00,5.00,'Personal transfer','2024-01-17 10:00:00',NULL,'failed'),
('TR018',18,31,1700.00,10.00,'Family transfer','2024-01-18 11:00:00','2024-01-18 11:05:00','completed'),
('TR019',19,33,1200.00,5.00,'Monthly payment','2024-01-19 12:00:00','2024-01-19 12:05:00','completed'),
('TR020',20,35,800.00,5.00,'Personal transfer','2024-01-20 13:00:00',NULL,'cancelled'),

('TR021',21,36,1450.00,10.00,'Family transfer','2024-01-21 09:00:00','2024-01-21 09:05:00','completed'),
('TR022',22,38,600.00,5.00,'Bill payment','2024-01-22 10:00:00','2024-01-22 10:05:00','completed'),
('TR023',23,40,2100.00,10.00,'Business payment','2024-01-23 11:00:00',NULL,'pending'),
('TR024',24,41,550.00,5.00,'Personal transfer','2024-01-24 12:00:00','2024-01-24 12:05:00','completed'),
('TR025',25,43,3200.00,15.00,'Business transfer','2024-01-25 13:00:00',NULL,'processing'),
('TR026',26,44,900.00,5.00,'Family transfer','2024-01-26 09:00:00','2024-01-26 09:05:00','completed'),
('TR027',27,46,750.00,5.00,'Personal transfer','2024-01-27 10:00:00',NULL,'failed'),
('TR028',28,47,1600.00,10.00,'Monthly payment','2024-01-28 11:00:00','2024-01-28 11:05:00','completed'),
('TR029',29,49,2000.00,10.00,'Family support','2024-01-29 12:00:00','2024-01-29 12:05:00','completed'),
('TR030',30,50,450.00,5.00,'Personal transfer','2024-01-30 13:00:00',NULL,'pending'),

('TR031',31,52,1150.00,5.00,'Family transfer','2024-02-01 09:00:00','2024-02-01 09:05:00','completed'),
('TR032',32,53,1300.00,10.00,'Bill payment','2024-02-02 10:00:00','2024-02-02 10:05:00','completed'),
('TR033',33,54,700.00,5.00,'Personal transfer','2024-02-03 11:00:00',NULL,'failed'),
('TR034',34,55,1800.00,10.00,'Family transfer','2024-02-04 12:00:00','2024-02-04 12:05:00','completed'),
('TR035',35,56,950.00,5.00,'Monthly payment','2024-02-05 13:00:00',NULL,'processing'),
('TR036',36,57,1450.00,10.00,'Personal transfer','2024-02-06 09:00:00','2024-02-06 09:05:00','completed'),
('TR037',37,58,800.00,5.00,'Family support','2024-02-07 10:00:00','2024-02-07 10:05:00','completed'),
('TR038',38,59,2200.00,10.00,'Business payment','2024-02-08 11:00:00',NULL,'pending'),
('TR039',39,60,650.00,5.00,'Personal transfer','2024-02-09 12:00:00',NULL,'cancelled'),
('TR040',40,61,1750.00,10.00,'Monthly payment','2024-02-10 13:00:00','2024-02-10 13:05:00','completed'),

('TR041',41,62,900.00,5.00,'Family transfer','2024-02-11 09:00:00','2024-02-11 09:05:00','completed'),
('TR042',42,63,2400.00,15.00,'Business payment','2024-02-12 10:00:00',NULL,'processing'),
('TR043',43,64,700.00,5.00,'Personal transfer','2024-02-13 11:00:00','2024-02-13 11:05:00','completed'),
('TR044',44,65,1100.00,10.00,'Bill payment','2024-02-14 12:00:00','2024-02-14 12:05:00','completed'),
('TR045',45,66,3500.00,15.00,'Business transfer','2024-02-15 13:00:00',NULL,'pending'),
('TR046',46,67,850.00,5.00,'Family support','2024-02-16 09:00:00','2024-02-16 09:05:00','completed'),
('TR047',47,68,1200.00,10.00,'Monthly payment','2024-02-17 10:00:00',NULL,'failed'),
('TR048',48,69,600.00,5.00,'Personal transfer','2024-02-18 11:00:00','2024-02-18 11:05:00','completed'),
('TR049',49,70,1800.00,10.00,'Family transfer','2024-02-19 12:00:00','2024-02-19 12:05:00','completed'),
('TR050',50,71,950.00,5.00,'Personal transfer','2024-02-20 13:00:00',NULL,'cancelled'),

('TR051',51,72,1300.00,10.00,'Bill payment','2024-02-21 09:00:00','2024-02-21 09:05:00','completed'),
('TR052',52,73,750.00,5.00,'Family transfer','2024-02-22 10:00:00','2024-02-22 10:05:00','completed'),
('TR053',53,74,2100.00,10.00,'Business payment','2024-02-23 11:00:00',NULL,'pending'),
('TR054',54,75,500.00,5.00,'Personal transfer','2024-02-24 12:00:00','2024-02-24 12:05:00','completed'),
('TR055',55,1,1500.00,10.00,'Family support','2024-02-25 13:00:00',NULL,'processing'),
('TR056',56,2,900.00,5.00,'Monthly payment','2024-02-26 09:00:00','2024-02-26 09:05:00','completed'),
('TR057',57,3,1200.00,10.00,'Personal transfer','2024-02-27 10:00:00','2024-02-27 10:05:00','completed'),
('TR058',58,4,800.00,5.00,'Family transfer','2024-02-28 11:00:00',NULL,'failed'),
('TR059',59,5,2300.00,10.00,'Business payment','2024-02-29 12:00:00','2024-02-29 12:05:00','completed'),
('TR060',60,6,650.00,5.00,'Personal transfer','2024-03-01 13:00:00',NULL,'pending'),

('TR061',61,7,1400.00,10.00,'Family transfer','2024-03-02 09:00:00','2024-03-02 09:05:00','completed'),
('TR062',62,8,950.00,5.00,'Bill payment','2024-03-03 10:00:00','2024-03-03 10:05:00','completed'),
('TR063',63,9,3000.00,15.00,'Business payment','2024-03-04 11:00:00',NULL,'processing'),
('TR064',64,10,700.00,5.00,'Personal transfer','2024-03-05 12:00:00','2024-03-05 12:05:00','completed'),
('TR065',65,11,1150.00,10.00,'Monthly payment','2024-03-06 13:00:00',NULL,'failed'),
('TR066',66,12,850.00,5.00,'Family support','2024-03-07 09:00:00','2024-03-07 09:05:00','completed'),
('TR067',67,13,1700.00,10.00,'Business transfer','2024-03-08 10:00:00','2024-03-08 10:05:00','completed'),
('TR068',68,14,600.00,5.00,'Personal transfer','2024-03-09 11:00:00',NULL,'pending'),
('TR069',69,15,2000.00,10.00,'Family transfer','2024-03-10 12:00:00','2024-03-10 12:05:00','completed'),
('TR070',70,16,900.00,5.00,'Bill payment','2024-03-11 13:00:00',NULL,'cancelled'),

('TR071',71,17,1250.00,10.00,'Family transfer','2024-03-12 09:00:00','2024-03-12 09:05:00','completed'),
('TR072',72,18,700.00,5.00,'Personal transfer','2024-03-13 10:00:00','2024-03-13 10:05:00','completed'),
('TR073',73,19,1600.00,10.00,'Monthly payment','2024-03-14 11:00:00',NULL,'pending'),
('TR074',74,20,800.00,5.00,'Family support','2024-03-15 12:00:00','2024-03-15 12:05:00','completed'),
('TR075',75,21,2400.00,15.00,'Business payment','2024-03-16 13:00:00',NULL,'processing'),
('TR076',1,22,550.00,5.00,'Personal transfer','2024-03-17 09:00:00','2024-03-17 09:05:00','completed'),
('TR077',2,23,1300.00,10.00,'Family transfer','2024-03-18 10:00:00','2024-03-18 10:05:00','completed'),
('TR078',3,24,900.00,5.00,'Bill payment','2024-03-19 11:00:00',NULL,'failed'),
('TR079',4,25,1750.00,10.00,'Business payment','2024-03-20 12:00:00','2024-03-20 12:05:00','completed'),
('TR080',5,26,650.00,5.00,'Personal transfer','2024-03-21 13:00:00',NULL,'pending'),

('TR081',6,27,1450.00,10.00,'Family transfer','2024-03-22 09:00:00','2024-03-22 09:05:00','completed'),
('TR082',7,28,800.00,5.00,'Monthly payment','2024-03-23 10:00:00','2024-03-23 10:05:00','completed'),
('TR083',8,29,2200.00,10.00,'Business payment','2024-03-24 11:00:00',NULL,'processing'),
('TR084',9,30,500.00,5.00,'Personal transfer','2024-03-25 12:00:00','2024-03-25 12:05:00','completed'),
('TR085',10,31,1000.00,10.00,'Family support','2024-03-26 13:00:00',NULL,'failed'),
('TR086',11,32,1350.00,10.00,'Bill payment','2024-03-27 09:00:00','2024-03-27 09:05:00','completed'),
('TR087',12,33,750.00,5.00,'Personal transfer','2024-03-28 10:00:00','2024-03-28 10:05:00','completed'),
('TR088',13,34,1800.00,10.00,'Family transfer','2024-03-29 11:00:00',NULL,'pending'),
('TR089',14,35,950.00,5.00,'Monthly payment','2024-03-30 12:00:00','2024-03-30 12:05:00','completed'),
('TR090',15,36,1250.00,10.00,'Personal transfer','2024-03-31 13:00:00',NULL,'cancelled'),

('TR091',16,37,700.00,5.00,'Family transfer','2024-04-01 09:00:00','2024-04-01 09:05:00','completed'),
('TR092',17,38,2100.00,10.00,'Business payment','2024-04-02 10:00:00','2024-04-02 10:05:00','completed'),
('TR093',18,39,600.00,5.00,'Personal transfer','2024-04-03 11:00:00',NULL,'pending'),
('TR094',19,40,1600.00,10.00,'Bill payment','2024-04-04 12:00:00','2024-04-04 12:05:00','completed'),
('TR095',20,41,900.00,5.00,'Family support','2024-04-05 13:00:00',NULL,'processing'),
('TR096',21,42,1450.00,10.00,'Monthly payment','2024-04-06 09:00:00','2024-04-06 09:05:00','completed'),
('TR097',22,43,800.00,5.00,'Personal transfer','2024-04-07 10:00:00',NULL,'failed'),
('TR098',23,44,1900.00,10.00,'Business transfer','2024-04-08 11:00:00','2024-04-08 11:05:00','completed'),
('TR099',24,45,550.00,5.00,'Family transfer','2024-04-09 12:00:00','2024-04-09 12:05:00','completed'),
('TR100',25,46,2500.00,15.00,'Business payment','2024-04-10 13:00:00',NULL,'pending'),

('TR101',26,47,750.00,5.00,'Personal transfer','2024-04-11 09:00:00','2024-04-11 09:05:00','completed'),
('TR102',27,48,1100.00,10.00,'Monthly payment','2024-04-12 10:00:00','2024-04-12 10:05:00','completed'),
('TR103',28,49,900.00,5.00,'Family support','2024-04-13 11:00:00',NULL,'failed'),
('TR104',29,50,1300.00,10.00,'Bill payment','2024-04-14 12:00:00','2024-04-14 12:05:00','completed'),
('TR105',30,51,650.00,5.00,'Personal transfer','2024-04-15 13:00:00',NULL,'processing'),
('TR106',31,52,1700.00,10.00,'Family transfer','2024-04-16 09:00:00','2024-04-16 09:05:00','completed'),
('TR107',32,53,850.00,5.00,'Monthly payment','2024-04-17 10:00:00','2024-04-17 10:05:00','completed'),
('TR108',33,54,2200.00,10.00,'Business payment','2024-04-18 11:00:00',NULL,'pending'),
('TR109',34,55,500.00,5.00,'Personal transfer','2024-04-19 12:00:00','2024-04-19 12:05:00','completed'),
('TR110',35,56,1200.00,10.00,'Family transfer','2024-04-20 13:00:00',NULL,'cancelled'),

('TR111',36,57,950.00,5.00,'Personal transfer','2024-04-21 09:00:00','2024-04-21 09:05:00','completed'),
('TR112',37,58,1500.00,10.00,'Bill payment','2024-04-22 10:00:00','2024-04-22 10:05:00','completed'),
('TR113',38,59,700.00,5.00,'Family support','2024-04-23 11:00:00',NULL,'pending'),
('TR114',39,60,1800.00,10.00,'Business payment','2024-04-24 12:00:00','2024-04-24 12:05:00','completed'),
('TR115',40,61,600.00,5.00,'Personal transfer','2024-04-25 13:00:00',NULL,'failed'),
('TR116',41,62,1250.00,10.00,'Monthly payment','2024-04-26 09:00:00','2024-04-26 09:05:00','completed'),
('TR117',42,63,900.00,5.00,'Family transfer','2024-04-27 10:00:00','2024-04-27 10:05:00','completed'),
('TR118',43,64,2400.00,15.00,'Business transfer','2024-04-28 11:00:00',NULL,'processing'),
('TR119',44,65,750.00,5.00,'Personal transfer','2024-04-29 12:00:00','2024-04-29 12:05:00','completed'),
('TR120',45,66,1350.00,10.00,'Family transfer','2024-04-30 13:00:00',NULL,'pending'),

('TR121',46,67,800.00,5.00,'Bill payment','2024-05-01 09:00:00','2024-05-01 09:05:00','completed'),
('TR122',47,68,2100.00,10.00,'Business payment','2024-05-02 10:00:00','2024-05-02 10:05:00','completed'),
('TR123',48,69,650.00,5.00,'Personal transfer','2024-05-03 11:00:00',NULL,'failed'),
('TR124',49,70,1000.00,10.00,'Family support','2024-05-04 12:00:00','2024-05-04 12:05:00','completed'),
('TR125',50,71,1450.00,10.00,'Monthly payment','2024-05-05 13:00:00',NULL,'processing'),
('TR126',51,72,900.00,5.00,'Personal transfer','2024-05-06 09:00:00','2024-05-06 09:05:00','completed'),
('TR127',52,73,1700.00,10.00,'Family transfer','2024-05-07 10:00:00','2024-05-07 10:05:00','completed'),
('TR128',53,74,700.00,5.00,'Bill payment','2024-05-08 11:00:00',NULL,'pending'),
('TR129',54,75,2300.00,10.00,'Business payment','2024-05-09 12:00:00','2024-05-09 12:05:00','completed'),
('TR130',55,1,550.00,5.00,'Personal transfer','2024-05-10 13:00:00',NULL,'cancelled'),

('TR131',56,2,1300.00,10.00,'Family transfer','2024-05-11 09:00:00','2024-05-11 09:05:00','completed'),
('TR132',57,3,850.00,5.00,'Monthly payment','2024-05-12 10:00:00','2024-05-12 10:05:00','completed'),
('TR133',58,4,1600.00,10.00,'Business payment','2024-05-13 11:00:00',NULL,'failed'),
('TR134',59,5,750.00,5.00,'Personal transfer','2024-05-14 12:00:00','2024-05-14 12:05:00','completed'),
('TR135',60,6,2000.00,10.00,'Family support','2024-05-15 13:00:00',NULL,'pending'),
('TR136',61,7,950.00,5.00,'Bill payment','2024-05-16 09:00:00','2024-05-16 09:05:00','completed'),
('TR137',62,8,1400.00,10.00,'Monthly payment','2024-05-17 10:00:00','2024-05-17 10:05:00','completed'),
('TR138',63,9,600.00,5.00,'Personal transfer','2024-05-18 11:00:00',NULL,'processing'),
('TR139',64,10,1850.00,10.00,'Family transfer','2024-05-19 12:00:00','2024-05-19 12:05:00','completed'),
('TR140',65,11,700.00,5.00,'Personal transfer','2024-05-20 13:00:00',NULL,'pending'),

('TR141',66,12,1250.00,10.00,'Family support','2024-05-21 09:00:00','2024-05-21 09:05:00','completed'),
('TR142',67,13,900.00,5.00,'Bill payment','2024-05-22 10:00:00','2024-05-22 10:05:00','completed'),
('TR143',68,14,2200.00,10.00,'Business payment','2024-05-23 11:00:00',NULL,'failed'),
('TR144',69,15,650.00,5.00,'Personal transfer','2024-05-24 12:00:00','2024-05-24 12:05:00','completed'),
('TR145',70,16,1500.00,10.00,'Family transfer','2024-05-25 13:00:00','2024-05-25 13:05:00','completed'),
('TR146',71,17,800.00,5.00,'Monthly payment','2024-05-26 09:00:00',NULL,'pending'),
('TR147',72,18,1100.00,10.00,'Personal transfer','2024-05-27 10:00:00','2024-05-27 10:05:00','completed'),
('TR148',73,19,1750.00,10.00,'Business transfer','2024-05-28 11:00:00',NULL,'processing'),
('TR149',74,20,500.00,5.00,'Family support','2024-05-29 12:00:00','2024-05-29 12:05:00','completed'),
('TR150',75,21,950.00,5.00,'Personal transfer','2024-05-30 13:00:00',NULL,'cancelled');


-- =========================================
-- TRANSACTIONS (400)
-- =========================================

INSERT INTO transactions
(account_id, transfer_id, transaction_type, amount,
 balance_before, balance_after, description, status)
VALUES
(1,NULL,'deposit',5000,7500,12500,'Cash deposit','completed'),
(2,NULL,'withdrawal',1000,46000,45000,'ATM withdrawal','completed'),
(3,1,'transfer_in',500,7700,8200,'Incoming transfer','completed'),
(4,2,'transfer_in',1000,11000,12000,'Incoming transfer','completed'),
(5,3,'transfer_out',750,16350,15600,'Outgoing transfer','pending'),
(6,4,'transfer_out',1200,10700,9500,'Outgoing transfer','failed'),
(7,5,'transfer_in',850,22150,23000,'Incoming transfer','completed'),
(8,6,'transfer_out',1500,68500,67000,'Outgoing transfer','completed'),
(9,NULL,'deposit',10000,140000,150000,'Business deposit','completed'),
(10,NULL,'withdrawal',900,10000,9100,'ATM withdrawal','completed'),

(11,7,'transfer_out',400,8200,7800,'Outgoing transfer','processing'),
(12,8,'transfer_in',2300,31700,34000,'Incoming transfer','completed'),
(13,9,'transfer_out',1800,7200,5400,'Outgoing transfer','pending'),
(14,10,'transfer_out',600,19300,18700,'Outgoing transfer','cancelled'),
(15,11,'transfer_in',950,28050,29000,'Incoming transfer','completed'),
(16,12,'transfer_out',1100,12400,11300,'Outgoing transfer','completed'),
(17,13,'transfer_in',700,14900,15600,'Incoming transfer','completed'),
(18,14,'transfer_out',2500,9700,7200,'Outgoing transfer','processing'),
(19,15,'transfer_out',900,9600,8700,'Outgoing transfer','pending'),
(20,16,'transfer_in',1300,17900,19200,'Incoming transfer','completed'),

(21,17,'transfer_out',650,8750,8100,'Outgoing transfer','failed'),
(22,18,'transfer_in',1700,39300,41000,'Incoming transfer','completed'),
(23,19,'transfer_out',1200,7900,6700,'Outgoing transfer','completed'),
(24,20,'transfer_out',800,53800,53000,'Outgoing transfer','cancelled'),
(25,21,'transfer_in',1450,183550,185000,'Incoming transfer','completed'),
(26,22,'transfer_out',600,9900,9300,'Outgoing transfer','completed'),
(27,23,'transfer_out',2100,13500,11400,'Outgoing transfer','pending'),
(28,24,'transfer_in',550,15550,16100,'Incoming transfer','completed'),
(29,25,'transfer_out',3200,52200,49000,'Outgoing transfer','processing'),
(30,26,'transfer_in',900,6700,7600,'Incoming transfer','completed'),

(31,27,'transfer_out',750,9650,8900,'Outgoing transfer','failed'),
(32,28,'transfer_in',1600,35400,37000,'Incoming transfer','completed'),
(33,29,'transfer_out',2000,14800,12800,'Outgoing transfer','completed'),
(34,30,'transfer_in',450,9750,10200,'Incoming transfer','pending'),
(35,31,'transfer_out',1150,22850,21700,'Outgoing transfer','completed'),
(36,32,'transfer_in',1300,59700,61000,'Incoming transfer','completed'),
(37,33,'transfer_out',700,220700,220000,'Outgoing transfer','failed'),
(38,34,'transfer_in',1800,5000,6800,'Incoming transfer','completed'),
(39,35,'transfer_out',950,14750,13800,'Outgoing transfer','processing'),
(40,36,'transfer_in',1450,15950,17400,'Incoming transfer','completed'),

(41,37,'transfer_in',800,32200,33000,'Incoming transfer','completed'),
(42,38,'transfer_out',2200,9800,7600,'Outgoing transfer','pending'),
(43,39,'transfer_out',650,45650,45000,'Outgoing transfer','cancelled'),
(44,40,'transfer_in',1750,8150,9900,'Incoming transfer','completed'),
(45,41,'transfer_out',900,175900,175000,'Outgoing transfer','completed'),
(46,42,'transfer_in',2400,11900,14300,'Incoming transfer','processing'),
(47,43,'transfer_out',700,9900,9200,'Outgoing transfer','completed'),
(48,44,'transfer_in',1100,17300,18400,'Incoming transfer','completed'),
(49,45,'transfer_out',3500,59500,56000,'Outgoing transfer','pending'),
(50,46,'transfer_in',850,7250,8100,'Incoming transfer','completed'),

(51,47,'transfer_out',1200,12700,11500,'Outgoing transfer','failed'),
(52,48,'transfer_in',600,12600,13200,'Incoming transfer','completed'),
(53,49,'transfer_out',1800,40800,39000,'Outgoing transfer','completed'),
(54,50,'transfer_out',950,5450,4500,'Outgoing transfer','cancelled'),
(55,51,'transfer_in',1300,25700,27000,'Incoming transfer','completed'),
(56,52,'transfer_out',750,7250,6500,'Outgoing transfer','completed'),
(57,53,'transfer_in',2100,6600,8700,'Incoming transfer','pending'),
(58,54,'transfer_out',500,12400,11900,'Outgoing transfer','completed'),
(59,55,'transfer_out',1500,32500,31000,'Outgoing transfer','processing'),
(60,56,'transfer_in',900,7800,8700,'Incoming transfer','completed'),

(61,57,'transfer_in',1200,13200,14400,'Incoming transfer','completed'),
(62,58,'transfer_out',800,11000,10200,'Outgoing transfer','failed'),
(63,59,'transfer_in',2300,95700,98000,'Incoming transfer','completed'),
(64,60,'transfer_out',650,8250,7600,'Outgoing transfer','pending'),
(65,61,'transfer_in',1400,27100,28500,'Incoming transfer','completed'),
(66,62,'transfer_out',950,8050,7100,'Outgoing transfer','completed'),
(67,63,'transfer_out',3000,39000,36000,'Outgoing transfer','processing'),
(68,64,'transfer_in',700,6100,6800,'Incoming transfer','completed'),
(69,65,'transfer_out',1150,43150,42000,'Outgoing transfer','failed'),
(70,66,'transfer_in',850,8450,9300,'Incoming transfer','completed'),

(71,67,'transfer_out',1700,13700,12000,'Outgoing transfer','completed'),
(72,68,'transfer_in',600,14900,15500,'Incoming transfer','pending'),
(73,69,'transfer_out',2000,49000,47000,'Outgoing transfer','completed'),
(74,70,'transfer_out',900,9100,8200,'Outgoing transfer','cancelled'),
(75,71,'transfer_in',1250,8450,9700,'Incoming transfer','completed'),

(1,NULL,'deposit',2000,10500,12500,'Salary deposit','completed'),
(2,NULL,'withdrawal',500,45500,45000,'ATM withdrawal','completed'),
(3,NULL,'deposit',1200,7000,8200,'Cash deposit','completed'),
(4,NULL,'withdrawal',800,12800,12000,'ATM withdrawal','completed'),
(5,NULL,'deposit',2500,13100,15600,'Salary deposit','completed'),
(6,NULL,'withdrawal',700,10200,9500,'ATM withdrawal','completed'),
(7,NULL,'deposit',1800,21200,23000,'Cash deposit','completed'),
(8,NULL,'withdrawal',1000,68000,67000,'ATM withdrawal','completed'),
(9,NULL,'deposit',5000,145000,150000,'Business deposit','completed'),
(10,NULL,'withdrawal',400,9500,9100,'ATM withdrawal','completed'),

(11,NULL,'deposit',1500,6300,7800,'Salary deposit','completed'),
(12,NULL,'withdrawal',600,34600,34000,'ATM withdrawal','completed'),
(13,NULL,'deposit',1000,4400,5400,'Cash deposit','completed'),
(14,NULL,'withdrawal',500,19200,18700,'ATM withdrawal','completed'),
(15,NULL,'deposit',2000,27000,29000,'Salary deposit','completed'),
(16,NULL,'withdrawal',700,12000,11300,'ATM withdrawal','completed'),
(17,NULL,'deposit',1000,14600,15600,'Cash deposit','completed'),
(18,NULL,'withdrawal',800,8000,7200,'ATM withdrawal','completed'),
(19,NULL,'deposit',1500,7200,8700,'Salary deposit','completed'),
(20,NULL,'withdrawal',500,19700,19200,'ATM withdrawal','completed'),

(21,NULL,'deposit',900,7200,8100,'Cash deposit','completed'),
(22,NULL,'withdrawal',1000,42000,41000,'ATM withdrawal','completed'),
(23,NULL,'deposit',800,5900,6700,'Salary deposit','completed'),
(24,NULL,'withdrawal',1000,54000,53000,'ATM withdrawal','completed'),
(25,NULL,'deposit',5000,180000,185000,'Business deposit','completed'),
(26,NULL,'withdrawal',500,9800,9300,'ATM withdrawal','completed'),
(27,NULL,'deposit',1000,10400,11400,'Cash deposit','completed'),
(28,NULL,'withdrawal',700,16800,16100,'ATM withdrawal','completed'),
(29,NULL,'deposit',2000,47000,49000,'Salary deposit','completed'),
(30,NULL,'withdrawal',600,8200,7600,'ATM withdrawal','completed'),

(31,NULL,'deposit',1200,7700,8900,'Cash deposit','completed'),
(32,NULL,'withdrawal',800,37800,37000,'ATM withdrawal','completed'),
(33,NULL,'deposit',3000,12500,15500,'Business deposit','completed'),
(34,NULL,'withdrawal',400,10600,10200,'ATM withdrawal','completed'),
(35,NULL,'deposit',2000,19700,21700,'Salary deposit','completed'),
(36,NULL,'withdrawal',1000,62000,61000,'ATM withdrawal','completed'),
(37,NULL,'deposit',5000,215000,220000,'Business deposit','completed'),
(38,NULL,'withdrawal',500,7300,6800,'ATM withdrawal','completed'),
(39,NULL,'deposit',1500,12300,13800,'Salary deposit','completed'),
(40,NULL,'withdrawal',700,18100,17400,'ATM withdrawal','completed'),

(41,NULL,'deposit',2000,31000,33000,'Cash deposit','completed'),
(42,NULL,'withdrawal',500,8100,7600,'ATM withdrawal','completed'),
(43,NULL,'deposit',2500,42500,45000,'Salary deposit','completed'),
(44,NULL,'withdrawal',600,10500,9900,'ATM withdrawal','completed'),
(45,NULL,'deposit',5000,170000,175000,'Business deposit','completed'),
(46,NULL,'withdrawal',800,11000,10200,'ATM withdrawal','completed'),
(47,NULL,'deposit',1000,8200,9200,'Cash deposit','completed'),
(48,NULL,'withdrawal',500,18900,18400,'ATM withdrawal','completed'),
(49,NULL,'deposit',3000,53000,56000,'Salary deposit','completed'),
(50,NULL,'withdrawal',400,8500,8100,'ATM withdrawal','completed'),

(51,NULL,'deposit',1500,10000,11500,'Cash deposit','completed'),
(52,NULL,'withdrawal',800,14000,13200,'ATM withdrawal','completed'),
(53,NULL,'deposit',2000,37000,39000,'Salary deposit','completed'),
(54,NULL,'withdrawal',500,5000,4500,'ATM withdrawal','completed'),
(55,NULL,'deposit',1000,26000,27000,'Cash deposit','completed'),
(56,NULL,'withdrawal',700,7200,6500,'ATM withdrawal','completed'),
(57,NULL,'deposit',1500,7200,8700,'Salary deposit','completed'),
(58,NULL,'withdrawal',500,12400,11900,'ATM withdrawal','completed'),
(59,NULL,'deposit',2500,28500,31000,'Cash deposit','completed'),
(60,NULL,'withdrawal',600,9300,8700,'ATM withdrawal','completed'),

(61,NULL,'deposit',2000,12400,14400,'Salary deposit','completed'),
(62,NULL,'withdrawal',700,10900,10200,'ATM withdrawal','completed'),
(63,NULL,'deposit',5000,93000,98000,'Business deposit','completed'),
(64,NULL,'withdrawal',500,8100,7600,'ATM withdrawal','completed'),
(65,NULL,'deposit',1500,27000,28500,'Cash deposit','completed'),
(66,NULL,'withdrawal',600,7700,7100,'ATM withdrawal','completed'),
(67,NULL,'deposit',3000,33000,36000,'Salary deposit','completed'),
(68,NULL,'withdrawal',500,7300,6800,'ATM withdrawal','completed'),
(69,NULL,'deposit',2500,39500,42000,'Cash deposit','completed'),
(70,NULL,'withdrawal',500,9800,9300,'ATM withdrawal','completed'),

(71,NULL,'deposit',1000,11000,12000,'Salary deposit','completed'),
(72,NULL,'withdrawal',500,16000,15500,'ATM withdrawal','completed'),
(73,NULL,'deposit',3000,44000,47000,'Cash deposit','completed'),
(74,NULL,'withdrawal',400,8600,8200,'ATM withdrawal','completed'),
(75,NULL,'deposit',1000,8700,9700,'Salary deposit','completed'),

(1,NULL,'fee',25,12500,12475,'Monthly service fee','completed'),
(2,NULL,'fee',15,45000,44985,'Account fee','completed'),
(3,NULL,'refund',100,8200,8300,'Refund','completed'),
(4,NULL,'fee',20,12000,11980,'Service fee','completed'),
(5,NULL,'loan_payment',850,15600,14750,'Loan payment','completed'),
(6,NULL,'fee',15,9500,9485,'Account fee','completed'),
(7,NULL,'refund',75,23000,23075,'Refund','completed'),
(8,NULL,'fee',25,67000,66975,'Monthly fee','completed'),
(9,NULL,'loan_payment',2000,150000,148000,'Loan payment','completed'),
(10,NULL,'fee',15,9100,9085,'Service fee','completed'),

(11,NULL,'loan_payment',900,7800,6900,'Loan payment','completed'),
(12,NULL,'fee',20,34000,33980,'Service fee','completed'),
(13,NULL,'refund',150,5400,5550,'Refund','completed'),
(14,NULL,'fee',15,18700,18685,'Account fee','completed'),
(15,NULL,'loan_payment',1200,29000,27800,'Loan payment','completed'),
(16,NULL,'fee',25,11300,11275,'Monthly fee','completed'),
(17,NULL,'refund',80,15600,15680,'Refund','completed'),
(18,NULL,'fee',15,7200,7185,'Service fee','completed'),
(19,NULL,'loan_payment',1000,8700,7700,'Loan payment','completed'),
(20,NULL,'fee',20,19200,19180,'Account fee','completed'),

(21,NULL,'loan_payment',750,8100,7350,'Loan payment','completed'),
(22,NULL,'fee',15,41000,40985,'Service fee','completed'),
(23,NULL,'refund',120,6700,6820,'Refund','completed'),
(24,NULL,'fee',25,53000,52975,'Monthly fee','completed'),
(25,NULL,'loan_payment',2500,185000,182500,'Loan payment','completed'),
(26,NULL,'fee',15,9300,9285,'Account fee','completed'),
(27,NULL,'refund',90,11400,11490,'Refund','completed'),
(28,NULL,'fee',20,16100,16080,'Service fee','completed'),
(29,NULL,'loan_payment',1400,49000,47600,'Loan payment','completed'),
(30,NULL,'fee',15,7600,7585,'Account fee','completed'),

(31,NULL,'loan_payment',1100,8900,7800,'Loan payment','completed'),
(32,NULL,'fee',25,37000,36975,'Monthly fee','completed'),
(33,NULL,'refund',200,15500,15700,'Refund','completed'),
(34,NULL,'fee',15,10200,10185,'Service fee','completed'),
(35,NULL,'loan_payment',900,21700,20800,'Loan payment','completed'),
(36,NULL,'fee',20,61000,60980,'Account fee','completed'),
(37,NULL,'loan_payment',3000,220000,217000,'Loan payment','completed'),
(38,NULL,'fee',15,6800,6785,'Service fee','completed'),
(39,NULL,'refund',100,13800,13900,'Refund','completed'),
(40,NULL,'fee',25,17400,17375,'Monthly fee','completed'),

(41,NULL,'loan_payment',850,33000,32150,'Loan payment','completed'),
(42,NULL,'fee',15,7600,7585,'Account fee','completed'),
(43,NULL,'refund',150,45000,45150,'Refund','completed'),
(44,NULL,'fee',20,9900,9880,'Service fee','completed'),
(45,NULL,'loan_payment',2200,175000,172800,'Loan payment','completed'),
(46,NULL,'fee',15,10200,10185,'Account fee','completed'),
(47,NULL,'refund',75,9200,9275,'Refund','completed'),
(48,NULL,'fee',25,18400,18375,'Monthly fee','completed'),
(49,NULL,'loan_payment',1500,56000,54500,'Loan payment','completed'),
(50,NULL,'fee',15,8100,8085,'Service fee','completed'),

(51,NULL,'loan_payment',800,11500,10700,'Loan payment','completed'),
(52,NULL,'fee',20,13200,13180,'Account fee','completed'),
(53,NULL,'refund',100,39000,39100,'Refund','completed'),
(54,NULL,'fee',15,4500,4485,'Service fee','completed'),
(55,NULL,'loan_payment',700,27000,26300,'Loan payment','completed'),
(56,NULL,'fee',20,6500,6480,'Account fee','completed'),
(57,NULL,'refund',90,8700,8790,'Refund','completed'),
(58,NULL,'fee',15,11900,11885,'Service fee','completed'),
(59,NULL,'loan_payment',1000,31000,30000,'Loan payment','completed'),
(60,NULL,'fee',25,8700,8675,'Monthly fee','completed'),

(61,NULL,'loan_payment',1200,14400,13200,'Loan payment','completed'),
(62,NULL,'fee',15,10200,10185,'Account fee','completed'),
(63,NULL,'loan_payment',3000,98000,95000,'Loan payment','completed'),
(64,NULL,'fee',20,7600,7580,'Service fee','completed'),
(65,NULL,'refund',125,28500,28625,'Refund','completed'),
(66,NULL,'fee',15,7100,7085,'Account fee','completed'),
(67,NULL,'loan_payment',1800,36000,34200,'Loan payment','completed'),
(68,NULL,'fee',20,6800,6780,'Service fee','completed'),
(69,NULL,'refund',100,42000,42100,'Refund','completed'),
(70,NULL,'fee',15,9300,9285,'Account fee','completed'),

(71,NULL,'loan_payment',900,12000,11100,'Loan payment','completed'),
(72,NULL,'fee',20,15500,15480,'Service fee','completed'),
(73,NULL,'refund',150,47000,47150,'Refund','completed'),
(74,NULL,'fee',15,8200,8185,'Account fee','completed'),
(75,NULL,'loan_payment',1000,9700,8700,'Loan payment','completed'),

(1,NULL,'deposit',3000,12475,15475,'Salary deposit','completed'),
(2,NULL,'withdrawal',1200,44985,43785,'ATM withdrawal','completed'),
(3,NULL,'deposit',800,8300,9100,'Cash deposit','completed'),
(4,NULL,'withdrawal',600,11980,11380,'ATM withdrawal','completed'),
(5,NULL,'deposit',2000,14750,16750,'Salary deposit','completed'),
(6,NULL,'withdrawal',500,9485,8985,'ATM withdrawal','completed'),
(7,NULL,'deposit',1500,23075,24575,'Cash deposit','completed'),
(8,NULL,'withdrawal',800,66975,66175,'ATM withdrawal','completed'),
(9,NULL,'deposit',4000,148000,152000,'Business deposit','completed'),
(10,NULL,'withdrawal',300,9085,8785,'ATM withdrawal','completed'),

(11,NULL,'deposit',1200,6900,8100,'Salary deposit','completed'),
(12,NULL,'withdrawal',500,33980,33480,'ATM withdrawal','completed'),
(13,NULL,'deposit',700,5550,6250,'Cash deposit','completed'),
(14,NULL,'withdrawal',400,18685,18285,'ATM withdrawal','completed'),
(15,NULL,'deposit',1800,27800,29600,'Salary deposit','completed'),
(16,NULL,'withdrawal',500,11275,10775,'ATM withdrawal','completed'),
(17,NULL,'deposit',900,15680,16580,'Cash deposit','completed'),
(18,NULL,'withdrawal',300,7185,6885,'ATM withdrawal','completed'),
(19,NULL,'deposit',1100,7700,8800,'Salary deposit','completed'),
(20,NULL,'withdrawal',700,19180,18480,'ATM withdrawal','completed'),

(21,NULL,'deposit',1000,7350,8350,'Cash deposit','completed'),
(22,NULL,'withdrawal',800,40985,40185,'ATM withdrawal','completed'),
(23,NULL,'deposit',900,6820,7720,'Salary deposit','completed'),
(24,NULL,'withdrawal',500,52975,52475,'ATM withdrawal','completed'),
(25,NULL,'deposit',4000,182500,186500,'Business deposit','completed'),
(26,NULL,'withdrawal',400,9285,8885,'ATM withdrawal','completed'),
(27,NULL,'deposit',700,11490,12190,'Cash deposit','completed'),
(28,NULL,'withdrawal',600,16080,15480,'ATM withdrawal','completed'),
(29,NULL,'deposit',2000,47600,49600,'Salary deposit','completed'),
(30,NULL,'withdrawal',300,7585,7285,'ATM withdrawal','completed'),

(31,NULL,'deposit',1000,7800,8800,'Cash deposit','completed'),
(32,NULL,'withdrawal',700,36975,36275,'ATM withdrawal','completed'),
(33,NULL,'deposit',2500,15700,18200,'Business deposit','completed'),
(34,NULL,'withdrawal',400,10185,9785,'ATM withdrawal','completed'),
(35,NULL,'deposit',1500,20800,22300,'Salary deposit','completed'),
(36,NULL,'withdrawal',800,60980,60180,'ATM withdrawal','completed'),
(37,NULL,'deposit',3500,217000,220500,'Business deposit','completed'),
(38,NULL,'withdrawal',300,6785,6485,'ATM withdrawal','completed'),
(39,NULL,'deposit',1200,13900,15100,'Salary deposit','completed'),
(40,NULL,'withdrawal',500,17375,16875,'ATM withdrawal','completed'),

(41,NULL,'deposit',1500,32150,33650,'Cash deposit','completed'),
(42,NULL,'withdrawal',400,7585,7185,'ATM withdrawal','completed'),
(43,NULL,'deposit',2000,45150,47150,'Salary deposit','completed'),
(44,NULL,'withdrawal',300,9880,9580,'ATM withdrawal','completed'),
(45,NULL,'deposit',4000,172800,176800,'Business deposit','completed'),
(46,NULL,'withdrawal',500,10185,9685,'ATM withdrawal','completed'),
(47,NULL,'deposit',800,9275,10075,'Cash deposit','completed'),
(48,NULL,'withdrawal',400,18375,17975,'ATM withdrawal','completed'),
(49,NULL,'deposit',2500,54500,57000,'Salary deposit','completed'),
(50,NULL,'withdrawal',300,8085,7785,'ATM withdrawal','completed'),

(51,NULL,'deposit',1000,10700,11700,'Cash deposit','completed'),
(52,NULL,'withdrawal',500,13180,12680,'ATM withdrawal','completed'),
(53,NULL,'deposit',1800,39100,40900,'Salary deposit','completed'),
(54,NULL,'withdrawal',300,4485,4185,'ATM withdrawal','completed'),
(55,NULL,'deposit',1200,26300,27500,'Cash deposit','completed'),
(56,NULL,'withdrawal',400,6480,6080,'ATM withdrawal','completed'),
(57,NULL,'deposit',800,8790,9590,'Salary deposit','completed'),
(58,NULL,'withdrawal',300,11885,11585,'ATM withdrawal','completed'),
(59,NULL,'deposit',2000,30000,32000,'Cash deposit','completed'),
(60,NULL,'withdrawal',500,8675,8175,'ATM withdrawal','completed'),

(61,NULL,'deposit',1500,13200,14700,'Salary deposit','completed'),
(62,NULL,'withdrawal',400,10185,9785,'ATM withdrawal','completed'),
(63,NULL,'deposit',5000,95000,100000,'Business deposit','completed'),
(64,NULL,'withdrawal',300,7580,7280,'ATM withdrawal','completed'),
(65,NULL,'deposit',1200,28625,29825,'Cash deposit','completed'),
(66,NULL,'withdrawal',400,7085,6685,'ATM withdrawal','completed'),
(67,NULL,'deposit',2500,34200,36700,'Salary deposit','completed'),
(68,NULL,'withdrawal',300,6780,6480,'ATM withdrawal','completed'),
(69,NULL,'deposit',2000,42100,44100,'Cash deposit','completed'),
(70,NULL,'withdrawal',300,9285,8985,'ATM withdrawal','completed'),

(71,NULL,'deposit',1000,11100,12100,'Salary deposit','completed'),
(72,NULL,'withdrawal',400,15480,15080,'ATM withdrawal','completed'),
(73,NULL,'deposit',2500,47150,49650,'Cash deposit','completed'),
(74,NULL,'withdrawal',300,8185,7885,'ATM withdrawal','completed'),
(75,NULL,'deposit',900,8700,9600,'Salary deposit','completed');


INSERT INTO transactions
(account_id, transfer_id, transaction_type, amount, balance_before, balance_after, description, status)
VALUES
(1,NULL,'deposit',500,5000,5500,'Cash deposit','completed'),
(2,NULL,'withdrawal',200,6000,5800,'ATM withdrawal','completed'),
(3,1,'transfer_in',1000,7000,8000,'Transfer received','completed'),
(4,2,'transfer_out',750,9000,8250,'Transfer sent','completed'),
(5,NULL,'deposit',1200,4500,5700,'Salary deposit','completed'),
(6,NULL,'withdrawal',300,8000,7700,'ATM withdrawal','completed'),
(7,3,'transfer_in',1500,5000,6500,'Transfer received','completed'),
(8,4,'transfer_out',600,7500,6900,'Transfer sent','completed'),
(9,NULL,'deposit',900,4000,4900,'Cash deposit','completed'),
(10,NULL,'withdrawal',150,5000,4850,'ATM withdrawal','completed'),

(11,5,'transfer_in',2000,6000,8000,'Transfer received','completed'),
(12,6,'transfer_out',800,9000,8200,'Transfer sent','completed'),
(13,NULL,'deposit',700,3500,4200,'Cash deposit','completed'),
(14,NULL,'withdrawal',250,7000,6750,'ATM withdrawal','completed'),
(15,7,'transfer_in',1100,5000,6100,'Transfer received','completed'),
(16,8,'transfer_out',450,6500,6050,'Transfer sent','completed'),
(17,NULL,'deposit',1300,4200,5500,'Cash deposit','completed'),
(18,NULL,'withdrawal',400,8000,7600,'ATM withdrawal','completed'),
(19,9,'transfer_in',900,3000,3900,'Transfer received','completed'),
(20,10,'transfer_out',350,6000,5650,'Transfer sent','completed'),

(21,NULL,'deposit',600,5000,5600,'Cash deposit','completed'),
(22,NULL,'withdrawal',180,7000,6820,'ATM withdrawal','completed'),
(23,11,'transfer_in',1250,4500,5750,'Transfer received','completed'),
(24,12,'transfer_out',550,8000,7450,'Transfer sent','completed'),
(25,NULL,'deposit',1000,6000,7000,'Salary deposit','completed'),
(26,NULL,'withdrawal',220,5000,4780,'ATM withdrawal','completed'),
(27,13,'transfer_in',1600,7000,8600,'Transfer received','completed'),
(28,14,'transfer_out',700,9000,8300,'Transfer sent','completed'),
(29,NULL,'deposit',850,3500,4350,'Cash deposit','completed'),
(30,NULL,'withdrawal',300,6000,5700,'ATM withdrawal','completed'),

(31,15,'transfer_in',1400,5000,6400,'Transfer received','completed'),
(32,16,'transfer_out',500,7500,7000,'Transfer sent','completed'),
(33,NULL,'deposit',750,4000,4750,'Cash deposit','completed'),
(34,NULL,'withdrawal',200,5500,5300,'ATM withdrawal','completed'),
(35,17,'transfer_in',1800,6000,7800,'Transfer received','completed'),
(36,18,'transfer_out',900,8500,7600,'Transfer sent','completed'),
(37,NULL,'deposit',1100,4500,5600,'Cash deposit','completed'),
(38,NULL,'withdrawal',350,7000,6650,'ATM withdrawal','completed'),
(39,19,'transfer_in',950,5000,5950,'Transfer received','completed'),
(40,20,'transfer_out',400,6500,6100,'Transfer sent','completed'),

(41,NULL,'deposit',500,3000,3500,'Cash deposit','completed'),
(42,NULL,'withdrawal',150,5000,4850,'ATM withdrawal','completed'),
(43,21,'transfer_in',1300,6000,7300,'Transfer received','completed'),
(44,22,'transfer_out',650,8000,7350,'Transfer sent','completed'),
(45,NULL,'deposit',900,4500,5400,'Cash deposit','completed'),
(46,NULL,'withdrawal',250,7000,6750,'ATM withdrawal','completed'),
(47,23,'transfer_in',1700,5000,6700,'Transfer received','completed'),
(48,24,'transfer_out',800,9000,8200,'Transfer sent','completed'),
(49,NULL,'deposit',1200,3500,4700,'Cash deposit','completed'),
(50,NULL,'withdrawal',300,6000,5700,'ATM withdrawal','completed'),

(51,25,'transfer_in',1000,5000,6000,'Transfer received','completed'),
(52,26,'transfer_out',450,7500,7050,'Transfer sent','completed'),
(53,NULL,'deposit',800,4000,4800,'Cash deposit','completed'),
(54,NULL,'withdrawal',200,5500,5300,'ATM withdrawal','completed'),
(55,27,'transfer_in',1500,6000,7500,'Transfer received','completed'),
(56,28,'transfer_out',700,8500,7800,'Transfer sent','completed'),
(57,NULL,'deposit',950,4500,5450,'Cash deposit','completed'),
(58,NULL,'withdrawal',250,7000,6750,'ATM withdrawal','completed'),
(59,29,'transfer_in',1200,5000,6200,'Transfer received','completed'),
(60,30,'transfer_out',500,6500,6000,'Transfer sent','completed'),

(61,NULL,'deposit',700,3500,4200,'Cash deposit','completed'),
(62,NULL,'withdrawal',180,5000,4820,'ATM withdrawal','completed'),
(63,31,'transfer_in',1600,6000,7600,'Transfer received','completed'),
(64,32,'transfer_out',600,8000,7400,'Transfer sent','completed'),
(65,NULL,'deposit',1000,4500,5500,'Salary deposit','completed'),
(66,NULL,'withdrawal',300,7000,6700,'ATM withdrawal','completed'),
(67,33,'transfer_in',1400,5000,6400,'Transfer received','completed'),
(68,34,'transfer_out',750,9000,8250,'Transfer sent','completed'),
(69,NULL,'deposit',850,4000,4850,'Cash deposit','completed'),
(70,NULL,'withdrawal',200,6000,5800,'ATM withdrawal','completed'),

(71,35,'transfer_in',1100,5000,6100,'Transfer received','completed'),
(72,36,'transfer_out',400,7500,7100,'Transfer sent','completed'),
(73,NULL,'deposit',1300,3500,4800,'Cash deposit','completed'),
(74,NULL,'withdrawal',250,7000,6750,'ATM withdrawal','completed'),
(75,37,'transfer_in',1800,6000,7800,'Transfer received','completed'),

(1,38,'transfer_out',850,8500,7650,'Transfer sent','completed'),
(2,NULL,'deposit',900,4500,5400,'Cash deposit','completed'),
(3,NULL,'withdrawal',350,7000,6650,'ATM withdrawal','completed'),
(4,39,'transfer_in',1250,5000,6250,'Transfer received','completed'),
(5,40,'transfer_out',550,6500,5950,'Transfer sent','completed'),

(6,NULL,'deposit',600,3000,3600,'Cash deposit','completed'),
(7,NULL,'withdrawal',150,5000,4850,'ATM withdrawal','completed'),
(8,41,'transfer_in',1450,6000,7450,'Transfer received','completed'),
(9,42,'transfer_out',650,8000,7350,'Transfer sent','completed'),
(10,NULL,'deposit',1050,4500,5550,'Cash deposit','completed'),

(11,NULL,'withdrawal',280,7000,6720,'ATM withdrawal','completed'),
(12,43,'transfer_in',1700,5000,6700,'Transfer received','completed'),
(13,44,'transfer_out',750,9000,8250,'Transfer sent','completed'),
(14,NULL,'deposit',800,3500,4300,'Cash deposit','completed'),
(15,NULL,'withdrawal',200,6000,5800,'ATM withdrawal','completed'),

(16,45,'transfer_in',1000,5000,6000,'Transfer received','completed'),
(17,46,'transfer_out',500,7500,7000,'Transfer sent','completed'),
(18,NULL,'deposit',1250,4000,5250,'Cash deposit','completed'),
(19,NULL,'withdrawal',300,7000,6700,'ATM withdrawal','completed'),
(20,47,'transfer_in',1500,6000,7500,'Transfer received','completed'),

(21,48,'transfer_out',800,8500,7700,'Transfer sent','completed'),
(22,NULL,'deposit',950,4500,5450,'Cash deposit','completed'),
(23,NULL,'withdrawal',250,7000,6750,'ATM withdrawal','completed'),
(24,49,'transfer_in',1200,5000,6200,'Transfer received','completed'),
(25,50,'transfer_out',600,6500,5900,'Transfer sent','completed');


/* four */

-- =========================================
-- CARDS (60)
-- =========================================

INSERT INTO cards
(account_id, card_number, card_type, issued_at, expiry_date, daily_limit, status)
VALUES
(1,'4000000000000001','debit','2023-01-10','2027-01-10',5000,'active'),
(2,'4000000000000002','credit','2023-02-15','2027-02-15',10000,'active'),
(3,'4000000000000003','debit','2023-03-20','2027-03-20',4000,'active'),
(4,'4000000000000004','debit','2023-04-05','2027-04-05',5000,'blocked'),
(5,'4000000000000005','credit','2023-05-12','2027-05-12',15000,'active'),
(6,'4000000000000006','debit','2023-06-18','2027-06-18',6000,'active'),
(7,'4000000000000007','debit','2023-07-22','2027-07-22',5000,'expired'),
(8,'4000000000000008','credit','2023-08-14','2027-08-14',12000,'active'),
(9,'4000000000000009','debit','2023-09-01','2027-09-01',7000,'active'),
(10,'4000000000000010','debit','2023-09-15','2027-09-15',4000,'cancelled'),

(11,'4000000000000011','credit','2023-10-01','2027-10-01',10000,'active'),
(12,'4000000000000012','debit','2023-10-10','2027-10-10',5000,'active'),
(13,'4000000000000013','debit','2023-10-20','2027-10-20',6000,'active'),
(14,'4000000000000014','credit','2023-11-01','2027-11-01',15000,'blocked'),
(15,'4000000000000015','debit','2023-11-12','2027-11-12',5000,'active'),
(16,'4000000000000016','credit','2023-11-20','2027-11-20',12000,'active'),
(17,'4000000000000017','debit','2023-12-01','2027-12-01',4000,'expired'),
(18,'4000000000000018','debit','2023-12-10','2027-12-10',5000,'active'),
(19,'4000000000000019','credit','2023-12-20','2027-12-20',15000,'active'),
(20,'4000000000000020','debit','2024-01-05','2028-01-05',6000,'active'),

(21,'4000000000000021','debit','2024-01-10','2028-01-10',5000,'active'),
(22,'4000000000000022','credit','2024-01-15','2028-01-15',12000,'active'),
(23,'4000000000000023','debit','2024-01-20','2028-01-20',4000,'blocked'),
(24,'4000000000000024','debit','2024-02-01','2028-02-01',7000,'active'),
(25,'4000000000000025','credit','2024-02-05','2028-02-05',15000,'active'),
(26,'4000000000000026','debit','2024-02-10','2028-02-10',5000,'expired'),
(27,'4000000000000027','debit','2024-02-15','2028-02-15',6000,'active'),
(28,'4000000000000028','credit','2024-02-20','2028-02-20',10000,'active'),
(29,'4000000000000029','debit','2024-03-01','2028-03-01',5000,'active'),
(30,'4000000000000030','credit','2024-03-05','2028-03-05',12000,'cancelled'),

(31,'4000000000000031','debit','2024-03-10','2028-03-10',4000,'active'),
(32,'4000000000000032','debit','2024-03-15','2028-03-15',5000,'active'),
(33,'4000000000000033','credit','2024-03-20','2028-03-20',15000,'blocked'),
(34,'4000000000000034','debit','2024-04-01','2028-04-01',6000,'active'),
(35,'4000000000000035','debit','2024-04-05','2028-04-05',5000,'active'),
(36,'4000000000000036','credit','2024-04-10','2028-04-10',10000,'expired'),
(37,'4000000000000037','debit','2024-04-15','2028-04-15',7000,'active'),
(38,'4000000000000038','credit','2024-04-20','2028-04-20',12000,'active'),
(39,'4000000000000039','debit','2024-05-01','2028-05-01',5000,'active'),
(40,'4000000000000040','debit','2024-05-05','2028-05-05',4000,'active'),

(41,'4000000000000041','credit','2024-05-10','2028-05-10',15000,'active'),
(42,'4000000000000042','debit','2024-05-15','2028-05-15',6000,'blocked'),
(43,'4000000000000043','debit','2024-05-20','2028-05-20',5000,'active'),
(44,'4000000000000044','credit','2024-06-01','2028-06-01',10000,'active'),
(45,'4000000000000045','debit','2024-06-05','2028-06-05',7000,'expired'),
(46,'4000000000000046','debit','2024-06-10','2028-06-10',5000,'active'),
(47,'4000000000000047','credit','2024-06-15','2028-06-15',15000,'active'),
(48,'4000000000000048','debit','2024-06-20','2028-06-20',4000,'cancelled'),
(49,'4000000000000049','debit','2024-07-01','2028-07-01',6000,'active'),
(50,'4000000000000050','credit','2024-07-05','2028-07-05',12000,'active'),

(51,'4000000000000051','debit','2024-07-10','2028-07-10',5000,'active'),
(52,'4000000000000052','credit','2024-07-15','2028-07-15',15000,'active'),
(53,'4000000000000053','debit','2024-07-20','2028-07-20',4000,'blocked'),
(54,'4000000000000054','debit','2024-08-01','2028-08-01',6000,'active'),
(55,'4000000000000055','credit','2024-08-05','2028-08-05',10000,'active'),
(56,'4000000000000056','debit','2024-08-10','2028-08-10',5000,'expired'),
(57,'4000000000000057','debit','2024-08-15','2028-08-15',7000,'active'),
(58,'4000000000000058','credit','2024-08-20','2028-08-20',12000,'active'),
(59,'4000000000000059','debit','2024-09-01','2028-09-01',5000,'active'),
(60,'4000000000000060','credit','2024-09-05','2028-09-05',15000,'active');


-- =========================================
-- CARD TRANSACTIONS (120)
-- =========================================

INSERT INTO card_transactions
(card_id, amount, merchant_name, transaction_type, transaction_date, status)
VALUES
(1,120.50,'Carrefour','purchase','2024-01-05 10:15:00','approved'),
(2,850.00,'Amazon','online_purchase','2024-01-06 11:20:00','approved'),
(3,75.00,'Starbucks','purchase','2024-01-07 09:10:00','approved'),
(4,250.00,'Uber','transport','2024-01-08 14:30:00','declined'),
(5,1500.00,'Noon','online_purchase','2024-01-09 16:45:00','approved'),
(6,320.00,'Lulu Market','purchase','2024-01-10 18:20:00','approved'),
(7,90.00,'McDonalds','purchase','2024-01-11 13:15:00','refunded'),
(8,2100.00,'Booking','hotel','2024-01-12 20:30:00','approved'),
(9,450.00,'IKEA','purchase','2024-01-13 12:00:00','approved'),
(10,130.00,'Uber Eats','food_delivery','2024-01-14 19:10:00','declined'),

(11,600.00,'Carrefour','purchase','2024-01-15 10:30:00','approved'),
(12,220.00,'Careem','transport','2024-01-16 15:20:00','approved'),
(13,95.00,'Starbucks','purchase','2024-01-17 09:45:00','approved'),
(14,1800.00,'Amazon','online_purchase','2024-01-18 17:30:00','declined'),
(15,350.00,'Lulu Market','purchase','2024-01-19 12:40:00','approved'),
(16,1250.00,'Noon','online_purchase','2024-01-20 16:10:00','approved'),
(17,75.00,'McDonalds','purchase','2024-01-21 13:20:00','refunded'),
(18,3000.00,'Booking','hotel','2024-01-22 21:00:00','approved'),
(19,550.00,'IKEA','purchase','2024-01-23 14:15:00','approved'),
(20,160.00,'Uber Eats','food_delivery','2024-01-24 19:45:00','approved'),

(21,430.00,'Carrefour','purchase','2024-02-01 11:00:00','approved'),
(22,900.00,'Amazon','online_purchase','2024-02-02 16:30:00','approved'),
(23,120.00,'Starbucks','purchase','2024-02-03 09:30:00','declined'),
(24,300.00,'Uber','transport','2024-02-04 15:20:00','approved'),
(25,1700.00,'Noon','online_purchase','2024-02-05 18:10:00','approved'),
(26,280.00,'Lulu Market','purchase','2024-02-06 12:50:00','refunded'),
(27,110.00,'McDonalds','purchase','2024-02-07 13:30:00','approved'),
(28,2500.00,'Booking','hotel','2024-02-08 20:45:00','approved'),
(29,700.00,'IKEA','purchase','2024-02-09 14:10:00','approved'),
(30,200.00,'Uber Eats','food_delivery','2024-02-10 19:20:00','declined'),

(31,520.00,'Carrefour','purchase','2024-02-11 10:20:00','approved'),
(32,1050.00,'Amazon','online_purchase','2024-02-12 17:00:00','approved'),
(33,80.00,'Starbucks','purchase','2024-02-13 09:15:00','approved'),
(34,275.00,'Careem','transport','2024-02-14 15:45:00','approved'),
(35,1900.00,'Noon','online_purchase','2024-02-15 18:30:00','declined'),
(36,360.00,'Lulu Market','purchase','2024-02-16 12:00:00','approved'),
(37,95.00,'McDonalds','purchase','2024-02-17 13:40:00','refunded'),
(38,2800.00,'Booking','hotel','2024-02-18 21:15:00','approved'),
(39,480.00,'IKEA','purchase','2024-02-19 14:40:00','approved'),
(40,145.00,'Uber Eats','food_delivery','2024-02-20 20:00:00','approved'),

(41,610.00,'Carrefour','purchase','2024-03-01 10:10:00','approved'),
(42,780.00,'Amazon','online_purchase','2024-03-02 16:20:00','approved'),
(43,105.00,'Starbucks','purchase','2024-03-03 09:40:00','declined'),
(44,330.00,'Uber','transport','2024-03-04 15:10:00','approved'),
(45,2200.00,'Noon','online_purchase','2024-03-05 18:50:00','approved'),
(46,290.00,'Lulu Market','purchase','2024-03-06 12:30:00','approved'),
(47,125.00,'McDonalds','purchase','2024-03-07 13:10:00','refunded'),
(48,3200.00,'Booking','hotel','2024-03-08 21:30:00','approved'),
(49,620.00,'IKEA','purchase','2024-03-09 14:25:00','approved'),
(50,175.00,'Uber Eats','food_delivery','2024-03-10 19:50:00','declined'),

(51,450.00,'Carrefour','purchase','2024-03-11 10:00:00','approved'),
(52,1150.00,'Amazon','online_purchase','2024-03-12 16:40:00','approved'),
(53,90.00,'Starbucks','purchase','2024-03-13 09:25:00','approved'),
(54,240.00,'Careem','transport','2024-03-14 15:00:00','approved'),
(55,1600.00,'Noon','online_purchase','2024-03-15 18:15:00','declined'),
(56,410.00,'Lulu Market','purchase','2024-03-16 12:45:00','approved'),
(57,100.00,'McDonalds','purchase','2024-03-17 13:25:00','refunded'),
(58,2700.00,'Booking','hotel','2024-03-18 20:50:00','approved'),
(59,590.00,'IKEA','purchase','2024-03-19 14:00:00','approved'),
(60,155.00,'Uber Eats','food_delivery','2024-03-20 19:30:00','approved'),

(1,200.00,'Carrefour','purchase','2024-04-01 10:10:00','approved'),
(2,700.00,'Amazon','online_purchase','2024-04-02 16:20:00','approved'),
(3,65.00,'Starbucks','purchase','2024-04-03 09:30:00','approved'),
(4,180.00,'Uber','transport','2024-04-04 15:00:00','declined'),
(5,950.00,'Noon','online_purchase','2024-04-05 18:20:00','approved'),
(6,300.00,'Lulu Market','purchase','2024-04-06 12:40:00','approved'),
(7,80.00,'McDonalds','purchase','2024-04-07 13:30:00','refunded'),
(8,1800.00,'Booking','hotel','2024-04-08 20:45:00','approved'),
(9,500.00,'IKEA','purchase','2024-04-09 14:20:00','approved'),
(10,120.00,'Uber Eats','food_delivery','2024-04-10 19:15:00','declined'),

(11,560.00,'Carrefour','purchase','2024-04-11 10:00:00','approved'),
(12,250.00,'Careem','transport','2024-04-12 15:20:00','approved'),
(13,110.00,'Starbucks','purchase','2024-04-13 09:20:00','approved'),
(14,1400.00,'Amazon','online_purchase','2024-04-14 17:10:00','declined'),
(15,390.00,'Lulu Market','purchase','2024-04-15 12:30:00','approved'),
(16,1000.00,'Noon','online_purchase','2024-04-16 16:30:00','approved'),
(17,90.00,'McDonalds','purchase','2024-04-17 13:20:00','refunded'),
(18,2300.00,'Booking','hotel','2024-04-18 21:10:00','approved'),
(19,430.00,'IKEA','purchase','2024-04-19 14:00:00','approved'),
(20,180.00,'Uber Eats','food_delivery','2024-04-20 19:40:00','approved'),

(21,480.00,'Carrefour','purchase','2024-05-01 10:15:00','approved'),
(22,950.00,'Amazon','online_purchase','2024-05-02 16:45:00','approved'),
(23,70.00,'Starbucks','purchase','2024-05-03 09:10:00','declined'),
(24,280.00,'Uber','transport','2024-05-04 15:30:00','approved'),
(25,1800.00,'Noon','online_purchase','2024-05-05 18:40:00','approved'),
(26,340.00,'Lulu Market','purchase','2024-05-06 12:20:00','refunded'),
(27,115.00,'McDonalds','purchase','2024-05-07 13:50:00','approved'),
(28,2900.00,'Booking','hotel','2024-05-08 21:20:00','approved'),
(29,650.00,'IKEA','purchase','2024-05-09 14:30:00','approved'),
(30,190.00,'Uber Eats','food_delivery','2024-05-10 19:25:00','declined'),

(31,530.00,'Carrefour','purchase','2024-05-11 10:30:00','approved'),
(32,880.00,'Amazon','online_purchase','2024-05-12 16:10:00','approved'),
(33,85.00,'Starbucks','purchase','2024-05-13 09:35:00','approved'),
(34,310.00,'Careem','transport','2024-05-14 15:40:00','approved'),
(35,1750.00,'Noon','online_purchase','2024-05-15 18:25:00','declined'),
(36,375.00,'Lulu Market','purchase','2024-05-16 12:15:00','approved'),
(37,105.00,'McDonalds','purchase','2024-05-17 13:45:00','refunded'),
(38,2600.00,'Booking','hotel','2024-05-18 20:55:00','approved'),
(39,540.00,'IKEA','purchase','2024-05-19 14:35:00','approved'),
(40,165.00,'Uber Eats','food_delivery','2024-05-20 19:55:00','approved');


/* five */

-- =========================================
-- LOANS (25)
-- =========================================

INSERT INTO loans
(customer_id, loan_number, principal_amount, interest_rate,
 total_amount, start_date, end_date, status)
VALUES
(1,'LN0001',20000,5.00,21000,'2024-01-01','2025-12-01','active'),
(2,'LN0002',35000,6.50,37275,'2024-01-15','2026-01-15','active'),
(3,'LN0003',15000,4.50,15675,'2024-02-01','2025-08-01','paid'),
(4,'LN0004',50000,7.00,53500,'2024-02-15','2027-02-15','active'),
(5,'LN0005',10000,5.00,10500,'2024-03-01','2025-03-01','paid'),

(6,'LN0006',25000,6.00,26500,'2024-03-15','2026-03-15','active'),
(7,'LN0007',40000,8.00,43200,'2024-04-01','2027-04-01','active'),
(8,'LN0008',18000,5.50,18990,'2024-04-15','2025-10-15','paid'),
(9,'LN0009',60000,7.50,64500,'2024-05-01','2028-05-01','active'),
(10,'LN0010',12000,4.00,12480,'2024-05-15','2025-05-15','paid'),

(11,'LN0011',30000,6.00,31800,'2024-06-01','2026-06-01','active'),
(12,'LN0012',45000,7.00,48150,'2024-06-15','2027-06-15','active'),
(13,'LN0013',22000,5.50,23210,'2024-07-01','2026-01-01','defaulted'),
(14,'LN0014',55000,8.00,59400,'2024-07-15','2028-07-15','active'),
(15,'LN0015',14000,5.00,14700,'2024-08-01','2025-08-01','paid'),

(16,'LN0016',28000,6.50,29820,'2024-08-15','2026-08-15','active'),
(17,'LN0017',75000,9.00,81750,'2024-09-01','2029-09-01','active'),
(18,'LN0018',16000,4.50,16720,'2024-09-15','2025-09-15','paid'),
(19,'LN0019',38000,7.00,40660,'2024-10-01','2027-10-01','active'),
(20,'LN0020',20000,5.50,21100,'2024-10-15','2026-04-15','cancelled'),

(21,'LN0021',42000,6.00,44520,'2024-11-01','2027-11-01','active'),
(22,'LN0022',18000,5.00,18900,'2024-11-15','2026-05-15','active'),
(23,'LN0023',65000,8.50,70525,'2024-12-01','2029-12-01','pending'),
(24,'LN0024',24000,6.00,25440,'2024-12-15','2026-12-15','active'),
(25,'LN0025',32000,7.50,34400,'2025-01-01','2027-01-01','active');


-- =========================================
-- LOAN INSTALLMENTS (150)
-- 6 installments for each of 25 loans
-- =========================================

INSERT INTO loan_installments
(loan_id, installment_number, due_date, amount, paid_amount, paid_at, status)
VALUES

-- Loan 1
(1,1,'2024-02-01',1750,1750,'2024-02-01 10:00:00','paid'),
(1,2,'2024-03-01',1750,1750,'2024-03-01 10:10:00','paid'),
(1,3,'2024-04-01',1750,1750,'2024-04-01 10:15:00','paid'),
(1,4,'2024-05-01',1750,1000,'2024-05-02 11:00:00','partially_paid'),
(1,5,'2024-06-01',1750,0,NULL,'pending'),
(1,6,'2024-07-01',1750,0,NULL,'pending'),

-- Loan 2
(2,1,'2024-02-15',3100,3100,'2024-02-15 09:00:00','paid'),
(2,2,'2024-03-15',3100,3100,'2024-03-15 09:20:00','paid'),
(2,3,'2024-04-15',3100,3100,'2024-04-15 09:30:00','paid'),
(2,4,'2024-05-15',3100,2000,'2024-05-16 10:00:00','partially_paid'),
(2,5,'2024-06-15',3100,0,NULL,'pending'),
(2,6,'2024-07-15',3100,0,NULL,'pending'),

-- Loan 3
(3,1,'2024-03-01',2612.50,2612.50,'2024-03-01 10:00:00','paid'),
(3,2,'2024-04-01',2612.50,2612.50,'2024-04-01 10:00:00','paid'),
(3,3,'2024-05-01',2612.50,2612.50,'2024-05-01 10:00:00','paid'),
(3,4,'2024-06-01',2612.50,2612.50,'2024-06-01 10:00:00','paid'),
(3,5,'2024-07-01',2612.50,2612.50,'2024-07-01 10:00:00','paid'),
(3,6,'2024-08-01',2612.50,2612.50,'2024-08-01 10:00:00','paid'),

-- Loan 4
(4,1,'2024-03-15',4458.33,4458.33,'2024-03-15 09:00:00','paid'),
(4,2,'2024-04-15',4458.33,4458.33,'2024-04-15 09:00:00','paid'),
(4,3,'2024-05-15',4458.33,3000,'2024-05-16 10:00:00','partially_paid'),
(4,4,'2024-06-15',4458.33,0,NULL,'overdue'),
(4,5,'2024-07-15',4458.33,0,NULL,'pending'),
(4,6,'2024-08-15',4458.33,0,NULL,'pending'),

-- Loan 5
(5,1,'2024-04-01',1750,1750,'2024-04-01 10:00:00','paid'),
(5,2,'2024-05-01',1750,1750,'2024-05-01 10:00:00','paid'),
(5,3,'2024-06-01',1750,1750,'2024-06-01 10:00:00','paid'),
(5,4,'2024-07-01',1750,1750,'2024-07-01 10:00:00','paid'),
(5,5,'2024-08-01',1750,1750,'2024-08-01 10:00:00','paid'),
(5,6,'2024-09-01',1750,1750,'2024-09-01 10:00:00','paid'),

-- Loan 6
(6,1,'2024-04-15',2208.33,2208.33,'2024-04-15 09:00:00','paid'),
(6,2,'2024-05-15',2208.33,2208.33,'2024-05-15 09:00:00','paid'),
(6,3,'2024-06-15',2208.33,2208.33,'2024-06-15 09:00:00','paid'),
(6,4,'2024-07-15',2208.33,1500,'2024-07-16 11:00:00','partially_paid'),
(6,5,'2024-08-15',2208.33,0,NULL,'pending'),
(6,6,'2024-09-15',2208.33,0,NULL,'pending'),

-- Loan 7
(7,1,'2024-05-01',3600,3600,'2024-05-01 10:00:00','paid'),
(7,2,'2024-06-01',3600,3600,'2024-06-01 10:00:00','paid'),
(7,3,'2024-07-01',3600,3600,'2024-07-01 10:00:00','paid'),
(7,4,'2024-08-01',3600,0,NULL,'overdue'),
(7,5,'2024-09-01',3600,0,NULL,'pending'),
(7,6,'2024-10-01',3600,0,NULL,'pending'),

-- Loan 8
(8,1,'2024-05-15',3165,3165,'2024-05-15 09:00:00','paid'),
(8,2,'2024-06-15',3165,3165,'2024-06-15 09:00:00','paid'),
(8,3,'2024-07-15',3165,3165,'2024-07-15 09:00:00','paid'),
(8,4,'2024-08-15',3165,3165,'2024-08-15 09:00:00','paid'),
(8,5,'2024-09-15',3165,3165,'2024-09-15 09:00:00','paid'),
(8,6,'2024-10-15',3165,3165,'2024-10-15 09:00:00','paid'),

-- Loan 9
(9,1,'2024-06-01',5375,5375,'2024-06-01 10:00:00','paid'),
(9,2,'2024-07-01',5375,5375,'2024-07-01 10:00:00','paid'),
(9,3,'2024-08-01',5375,4000,'2024-08-02 10:00:00','partially_paid'),
(9,4,'2024-09-01',5375,0,NULL,'pending'),
(9,5,'2024-10-01',5375,0,NULL,'pending'),
(9,6,'2024-11-01',5375,0,NULL,'pending'),

-- Loan 10
(10,1,'2024-06-15',2080,2080,'2024-06-15 09:00:00','paid'),
(10,2,'2024-07-15',2080,2080,'2024-07-15 09:00:00','paid'),
(10,3,'2024-08-15',2080,2080,'2024-08-15 09:00:00','paid'),
(10,4,'2024-09-15',2080,2080,'2024-09-15 09:00:00','paid'),
(10,5,'2024-10-15',2080,2080,'2024-10-15 09:00:00','paid'),
(10,6,'2024-11-15',2080,2080,'2024-11-15 09:00:00','paid'),

-- Loan 11
(11,1,'2024-07-01',5300,5300,'2024-07-01 10:00:00','paid'),
(11,2,'2024-08-01',5300,5300,'2024-08-01 10:00:00','paid'),
(11,3,'2024-09-01',5300,5300,'2024-09-01 10:00:00','paid'),
(11,4,'2024-10-01',5300,3000,'2024-10-02 11:00:00','partially_paid'),
(11,5,'2024-11-01',5300,0,NULL,'pending'),
(11,6,'2024-12-01',5300,0,NULL,'pending'),

-- Loan 12
(12,1,'2024-07-15',8025,8025,'2024-07-15 09:00:00','paid'),
(12,2,'2024-08-15',8025,8025,'2024-08-15 09:00:00','paid'),
(12,3,'2024-09-15',8025,5000,'2024-09-16 10:00:00','partially_paid'),
(12,4,'2024-10-15',8025,0,NULL,'overdue'),
(12,5,'2024-11-15',8025,0,NULL,'pending'),
(12,6,'2024-12-15',8025,0,NULL,'pending'),

-- Loan 13
(13,1,'2024-08-01',3868.33,3868.33,'2024-08-01 10:00:00','paid'),
(13,2,'2024-09-01',3868.33,3868.33,'2024-09-01 10:00:00','paid'),
(13,3,'2024-10-01',3868.33,1000,'2024-10-03 10:00:00','partially_paid'),
(13,4,'2024-11-01',3868.33,0,NULL,'overdue'),
(13,5,'2024-12-01',3868.33,0,NULL,'overdue'),
(13,6,'2025-01-01',3868.33,0,NULL,'pending'),

-- Loan 14
(14,1,'2024-08-15',9900,9900,'2024-08-15 09:00:00','paid'),
(14,2,'2024-09-15',9900,9900,'2024-09-15 09:00:00','paid'),
(14,3,'2024-10-15',9900,9900,'2024-10-15 09:00:00','paid'),
(14,4,'2024-11-15',9900,5000,'2024-11-16 10:00:00','partially_paid'),
(14,5,'2024-12-15',9900,0,NULL,'pending'),
(14,6,'2025-01-15',9900,0,NULL,'pending'),

-- Loan 15
(15,1,'2024-09-01',2450,2450,'2024-09-01 10:00:00','paid'),
(15,2,'2024-10-01',2450,2450,'2024-10-01 10:00:00','paid'),
(15,3,'2024-11-01',2450,2450,'2024-11-01 10:00:00','paid'),
(15,4,'2024-12-01',2450,2450,'2024-12-01 10:00:00','paid'),
(15,5,'2025-01-01',2450,2450,'2025-01-01 10:00:00','paid'),
(15,6,'2025-02-01',2450,2450,'2025-02-01 10:00:00','paid'),

-- Loan 16
(16,1,'2024-09-15',4970,4970,'2024-09-15 09:00:00','paid'),
(16,2,'2024-10-15',4970,4970,'2024-10-15 09:00:00','paid'),
(16,3,'2024-11-15',4970,3000,'2024-11-16 10:00:00','partially_paid'),
(16,4,'2024-12-15',4970,0,NULL,'pending'),
(16,5,'2025-01-15',4970,0,NULL,'pending'),
(16,6,'2025-02-15',4970,0,NULL,'pending'),

-- Loan 17
(17,1,'2024-10-01',13625,13625,'2024-10-01 10:00:00','paid'),
(17,2,'2024-11-01',13625,13625,'2024-11-01 10:00:00','paid'),
(17,3,'2024-12-01',13625,13625,'2024-12-01 10:00:00','paid'),
(17,4,'2025-01-01',13625,7000,'2025-01-02 10:00:00','partially_paid'),
(17,5,'2025-02-01',13625,0,NULL,'pending'),
(17,6,'2025-03-01',13625,0,NULL,'pending'),

-- Loan 18
(18,1,'2024-10-15',2786.67,2786.67,'2024-10-15 09:00:00','paid'),
(18,2,'2024-11-15',2786.67,2786.67,'2024-11-15 09:00:00','paid'),
(18,3,'2024-12-15',2786.67,2786.67,'2024-12-15 09:00:00','paid'),
(18,4,'2025-01-15',2786.67,2786.67,'2025-01-15 09:00:00','paid'),
(18,5,'2025-02-15',2786.67,2786.67,'2025-02-15 09:00:00','paid'),
(18,6,'2025-03-15',2786.67,2786.67,'2025-03-15 09:00:00','paid'),

-- Loan 19
(19,1,'2024-11-01',6776.67,6776.67,'2024-11-01 10:00:00','paid'),
(19,2,'2024-12-01',6776.67,6776.67,'2024-12-01 10:00:00','paid'),
(19,3,'2025-01-01',6776.67,3000,'2025-01-02 10:00:00','partially_paid'),
(19,4,'2025-02-01',6776.67,0,NULL,'pending'),
(19,5,'2025-03-01',6776.67,0,NULL,'pending'),
(19,6,'2025-04-01',6776.67,0,NULL,'pending'),

-- Loan 20
(20,1,'2024-11-15',3516.67,0,NULL,'overdue'),
(20,2,'2024-12-15',3516.67,0,NULL,'overdue'),
(20,3,'2025-01-15',3516.67,0,NULL,'pending'),
(20,4,'2025-02-15',3516.67,0,NULL,'pending'),
(20,5,'2025-03-15',3516.67,0,NULL,'pending'),
(20,6,'2025-04-15',3516.67,0,NULL,'pending'),

-- Loan 21
(21,1,'2024-12-01',7420,7420,'2024-12-01 10:00:00','paid'),
(21,2,'2025-01-01',7420,7420,'2025-01-01 10:00:00','paid'),
(21,3,'2025-02-01',7420,4000,'2025-02-02 10:00:00','partially_paid'),
(21,4,'2025-03-01',7420,0,NULL,'pending'),
(21,5,'2025-04-01',7420,0,NULL,'pending'),
(21,6,'2025-05-01',7420,0,NULL,'pending'),

-- Loan 22
(22,1,'2024-12-15',3150,3150,'2024-12-15 09:00:00','paid'),
(22,2,'2025-01-15',3150,3150,'2025-01-15 09:00:00','paid'),
(22,3,'2025-02-15',3150,3150,'2025-02-15 09:00:00','paid'),
(22,4,'2025-03-15',3150,1500,'2025-03-16 10:00:00','partially_paid'),
(22,5,'2025-04-15',3150,0,NULL,'pending'),
(22,6,'2025-05-15',3150,0,NULL,'pending'),

-- Loan 23
(23,1,'2025-01-01',11754.17,0,NULL,'pending'),
(23,2,'2025-02-01',11754.17,0,NULL,'pending'),
(23,3,'2025-03-01',11754.17,0,NULL,'pending'),
(23,4,'2025-04-01',11754.17,0,NULL,'pending'),
(23,5,'2025-05-01',11754.17,0,NULL,'pending'),
(23,6,'2025-06-01',11754.17,0,NULL,'pending'),

-- Loan 24
(24,1,'2025-01-15',4240,4240,'2025-01-15 09:00:00','paid'),
(24,2,'2025-02-15',4240,4240,'2025-02-15 09:00:00','paid'),
(24,3,'2025-03-15',4240,2000,'2025-03-16 10:00:00','partially_paid'),
(24,4,'2025-04-15',4240,0,NULL,'pending'),
(24,5,'2025-05-15',4240,0,NULL,'pending'),
(24,6,'2025-06-15',4240,0,NULL,'pending'),

-- Loan 25
(25,1,'2025-02-01',5733.33,5733.33,'2025-02-01 10:00:00','paid'),
(25,2,'2025-03-01',5733.33,5733.33,'2025-03-01 10:00:00','paid'),
(25,3,'2025-04-01',5733.33,5733.33,'2025-04-01 10:00:00','paid'),
(25,4,'2025-05-01',5733.33,3000,'2025-05-02 10:00:00','partially_paid'),
(25,5,'2025-06-01',5733.33,0,NULL,'pending'),
(25,6,'2025-07-01',5733.33,0,NULL,'pending');


/* six & final */

-- =========================================
-- AUDIT LOGS (100)
-- =========================================

INSERT INTO audit_logs
(customer_id, account_id, action_type, table_name, record_id, old_value, new_value, created_at)
VALUES
(1,1,'CREATE','customers',1,NULL,'Customer created','2024-01-01 09:00:00'),
(2,2,'UPDATE','customers',2,'status=inactive','status=active','2024-01-02 10:00:00'),
(3,3,'UPDATE','accounts',3,'balance=5000','balance=7500','2024-01-03 11:00:00'),
(4,4,'CREATE','accounts',4,NULL,'Account created','2024-01-04 12:00:00'),
(5,5,'UPDATE','accounts',5,'status=frozen','status=active','2024-01-05 13:00:00'),
(6,6,'CREATE','beneficiaries',1,NULL,'Beneficiary created','2024-01-06 09:30:00'),
(7,7,'UPDATE','beneficiaries',2,'status=inactive','status=active','2024-01-07 10:30:00'),
(8,8,'CREATE','transfers',1,NULL,'Transfer created','2024-01-08 11:30:00'),
(9,9,'UPDATE','transfers',2,'status=pending','status=completed','2024-01-09 12:30:00'),
(10,10,'UPDATE','transfers',3,'status=processing','status=completed','2024-01-10 13:30:00'),

(11,11,'CREATE','transactions',1,NULL,'Transaction created','2024-01-11 09:00:00'),
(12,12,'UPDATE','transactions',2,'status=pending','status=completed','2024-01-12 10:00:00'),
(13,13,'CREATE','cards',1,NULL,'Card issued','2024-01-13 11:00:00'),
(14,14,'UPDATE','cards',2,'status=blocked','status=active','2024-01-14 12:00:00'),
(15,15,'UPDATE','cards',3,'status=active','status=blocked','2024-01-15 13:00:00'),
(16,16,'CREATE','card_transactions',1,NULL,'Card transaction created','2024-01-16 09:15:00'),
(17,17,'UPDATE','card_transactions',2,'status=pending','status=approved','2024-01-17 10:15:00'),
(18,18,'UPDATE','card_transactions',3,'status=approved','status=refunded','2024-01-18 11:15:00'),
(19,19,'CREATE','loans',1,NULL,'Loan created','2024-01-19 12:15:00'),
(20,20,'UPDATE','loans',2,'status=pending','status=active','2024-01-20 13:15:00'),

(21,21,'UPDATE','loans',3,'status=active','status=paid','2024-01-21 09:00:00'),
(22,22,'CREATE','loan_installments',1,NULL,'Installment created','2024-01-22 10:00:00'),
(23,23,'UPDATE','loan_installments',2,'paid_amount=0','paid_amount=1500','2024-01-23 11:00:00'),
(24,24,'UPDATE','loan_installments',3,'status=pending','status=paid','2024-01-24 12:00:00'),
(25,25,'UPDATE','loan_installments',4,'status=pending','status=overdue','2024-01-25 13:00:00'),

(1,1,'LOGIN','customers',1,NULL,'Successful login','2024-02-01 09:00:00'),
(2,2,'LOGIN','customers',2,NULL,'Successful login','2024-02-01 10:00:00'),
(3,3,'LOGIN_FAILED','customers',3,NULL,'Invalid password','2024-02-01 11:00:00'),
(4,4,'LOGIN','customers',4,NULL,'Successful login','2024-02-01 12:00:00'),
(5,5,'LOGIN_FAILED','customers',5,NULL,'Invalid password','2024-02-01 13:00:00'),
(6,6,'UPDATE','accounts',6,'balance=8000','balance=9200','2024-02-02 09:00:00'),
(7,7,'UPDATE','accounts',7,'status=active','status=frozen','2024-02-02 10:00:00'),
(8,8,'UPDATE','accounts',8,'status=frozen','status=active','2024-02-02 11:00:00'),
(9,9,'CREATE','transfers',10,NULL,'Transfer created','2024-02-02 12:00:00'),
(10,10,'UPDATE','transfers',11,'status=pending','status=failed','2024-02-02 13:00:00'),

(11,11,'CREATE','transactions',10,NULL,'Deposit transaction','2024-02-03 09:00:00'),
(12,12,'CREATE','transactions',11,NULL,'Withdrawal transaction','2024-02-03 10:00:00'),
(13,13,'CREATE','cards',13,NULL,'Card issued','2024-02-03 11:00:00'),
(14,14,'UPDATE','cards',14,'status=active','status=blocked','2024-02-03 12:00:00'),
(15,15,'UPDATE','cards',15,'status=blocked','status=active','2024-02-03 13:00:00'),
(16,16,'CREATE','card_transactions',16,NULL,'Purchase created','2024-02-04 09:00:00'),
(17,17,'UPDATE','card_transactions',17,'status=pending','status=declined','2024-02-04 10:00:00'),
(18,18,'UPDATE','card_transactions',18,'status=approved','status=refunded','2024-02-04 11:00:00'),
(19,19,'CREATE','loans',19,NULL,'Loan application created','2024-02-04 12:00:00'),
(20,20,'UPDATE','loans',20,'status=pending','status=cancelled','2024-02-04 13:00:00'),

(21,21,'CREATE','loan_installments',21,NULL,'Installment created','2024-02-05 09:00:00'),
(22,22,'UPDATE','loan_installments',22,'paid_amount=0','paid_amount=3000','2024-02-05 10:00:00'),
(23,23,'UPDATE','loan_installments',23,'status=pending','status=partially_paid','2024-02-05 11:00:00'),
(24,24,'UPDATE','loan_installments',24,'status=pending','status=overdue','2024-02-05 12:00:00'),
(25,25,'UPDATE','loan_installments',25,'status=partially_paid','status=paid','2024-02-05 13:00:00'),

(1,1,'UPDATE','customers',1,'city=Riyadh','city=Jeddah','2024-02-06 09:00:00'),
(2,2,'UPDATE','customers',2,'status=active','status=blocked','2024-02-06 10:00:00'),
(3,3,'UPDATE','customers',3,'status=blocked','status=active','2024-02-06 11:00:00'),
(4,4,'UPDATE','accounts',4,'currency=SAR','currency=USD','2024-02-06 12:00:00'),
(5,5,'UPDATE','accounts',5,'balance=10000','balance=12500','2024-02-06 13:00:00'),
(6,6,'CREATE','beneficiaries',6,NULL,'Beneficiary created','2024-02-07 09:00:00'),
(7,7,'UPDATE','beneficiaries',7,'status=active','status=inactive','2024-02-07 10:00:00'),
(8,8,'CREATE','transfers',20,NULL,'Transfer created','2024-02-07 11:00:00'),
(9,9,'UPDATE','transfers',21,'status=pending','status=completed','2024-02-07 12:00:00'),
(10,10,'UPDATE','transfers',22,'status=pending','status=cancelled','2024-02-07 13:00:00'),

(11,11,'CREATE','transactions',20,NULL,'Deposit transaction','2024-02-08 09:00:00'),
(12,12,'CREATE','transactions',21,NULL,'Transfer transaction','2024-02-08 10:00:00'),
(13,13,'UPDATE','cards',20,'status=active','status=blocked','2024-02-08 11:00:00'),
(14,14,'UPDATE','cards',21,'status=blocked','status=active','2024-02-08 12:00:00'),
(15,15,'CREATE','card_transactions',25,NULL,'Purchase created','2024-02-08 13:00:00'),
(16,16,'UPDATE','card_transactions',26,'status=pending','status=approved','2024-02-09 09:00:00'),
(17,17,'UPDATE','card_transactions',27,'status=approved','status=refunded','2024-02-09 10:00:00'),
(18,18,'CREATE','loans',21,NULL,'Loan created','2024-02-09 11:00:00'),
(19,19,'UPDATE','loans',22,'status=pending','status=active','2024-02-09 12:00:00'),
(20,20,'UPDATE','loans',23,'status=pending','status=active','2024-02-09 13:00:00'),

(21,21,'CREATE','loan_installments',31,NULL,'Installment created','2024-02-10 09:00:00'),
(22,22,'UPDATE','loan_installments',32,'paid_amount=0','paid_amount=2500','2024-02-10 10:00:00'),
(23,23,'UPDATE','loan_installments',33,'status=pending','status=paid','2024-02-10 11:00:00'),
(24,24,'UPDATE','loan_installments',34,'status=pending','status=overdue','2024-02-10 12:00:00'),
(25,25,'UPDATE','loan_installments',35,'status=partially_paid','status=paid','2024-02-10 13:00:00'),

(1,1,'LOGIN','customers',1,NULL,'Successful login','2024-02-11 09:00:00'),
(2,2,'LOGIN','customers',2,NULL,'Successful login','2024-02-11 10:00:00'),
(3,3,'LOGIN_FAILED','customers',3,NULL,'Invalid password','2024-02-11 11:00:00'),
(4,4,'LOGIN','customers',4,NULL,'Successful login','2024-02-11 12:00:00'),
(5,5,'LOGIN_FAILED','customers',5,NULL,'Invalid password','2024-02-11 13:00:00'),
(6,6,'UPDATE','accounts',16,'balance=7000','balance=9500','2024-02-12 09:00:00'),
(7,7,'UPDATE','accounts',17,'status=active','status=frozen','2024-02-12 10:00:00'),
(8,8,'UPDATE','accounts',18,'status=frozen','status=active','2024-02-12 11:00:00'),
(9,9,'CREATE','transfers',40,NULL,'Transfer created','2024-02-12 12:00:00'),
(10,10,'UPDATE','transfers',41,'status=pending','status=completed','2024-02-12 13:00:00'),

(11,11,'CREATE','transactions',40,NULL,'Deposit transaction','2024-02-13 09:00:00'),
(12,12,'CREATE','transactions',41,NULL,'Withdrawal transaction','2024-02-13 10:00:00'),
(13,13,'UPDATE','cards',30,'status=active','status=cancelled','2024-02-13 11:00:00'),
(14,14,'UPDATE','cards',31,'status=blocked','status=active','2024-02-13 12:00:00'),
(15,15,'CREATE','card_transactions',50,NULL,'Purchase created','2024-02-13 13:00:00'),
(16,16,'UPDATE','card_transactions',51,'status=pending','status=approved','2024-02-14 09:00:00'),
(17,17,'UPDATE','card_transactions',52,'status=approved','status=refunded','2024-02-14 10:00:00'),
(18,18,'CREATE','loans',24,NULL,'Loan created','2024-02-14 11:00:00'),
(19,19,'UPDATE','loans',24,'status=pending','status=active','2024-02-14 12:00:00'),
(20,20,'UPDATE','loans',25,'status=pending','status=active','2024-02-14 13:00:00');



-- 2. العملاء الذين لديهم أكثر من حساب
SELECT c.full_name, COUNT(a.id) AS accounts
FROM customers c
JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id
HAVING COUNT(a.id) > 1;

-- 3. العملاء الذين لديهم أكثر من عملة
SELECT c.full_name, COUNT(DISTINCT a.currency) AS currencies
FROM customers c
JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id
HAVING COUNT(DISTINCT a.currency) > 1;

-- 4. إجمالي الرصيد لكل عميل
SELECT c.full_name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id;

-- 5. الحسابات التي لم تنفذ أي حركة
SELECT a.account_number
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
WHERE t.id IS NULL;

-- Transactions
-- 6. عدد Transactions لكل حساب
SELECT account_id, COUNT(*) AS transaction_count
FROM transactions
GROUP BY account_id;

-- 7. الحسابات التي لديها أكثر من 20 Transaction
SELECT account_id, COUNT(*) AS transaction_count
FROM transactions
GROUP BY account_id
HAVING COUNT(*) > 20;

-- 8. إجمالي Deposits لكل حساب
SELECT account_id, SUM(amount) AS total_deposits
FROM transactions
WHERE transaction_type = 'deposit'
GROUP BY account_id;

-- 9. إجمالي Withdrawals لكل حساب
SELECT account_id, SUM(amount) AS total_withdrawals
FROM transactions
WHERE transaction_type = 'withdrawal'
GROUP BY account_id;

-- 10. الفرق بين Deposits و Withdrawals
SELECT account_id,
SUM(CASE WHEN transaction_type = 'deposit' THEN amount ELSE 0 END)
-
SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END)
AS difference
FROM transactions
GROUP BY account_id;

-- 11. أعلى 10 حسابات من حيث الحركة
SELECT account_id, SUM(amount) AS total
FROM transactions
GROUP BY account_id
ORDER BY total DESC
LIMIT 10;

-- 12. التحويلات الفاشلة
SELECT *
FROM transfers
WHERE status = 'failed';

-- 13. التحويلات Pending
SELECT *
FROM transfers
WHERE status = 'pending';

-- 14. متوسط قيمة التحويل
SELECT AVG(amount) AS average_transfer
FROM transfers;

-- 15. التحويلات الأعلى من المتوسط
SELECT *
FROM transfers
WHERE amount > (SELECT AVG(amount) FROM transfers);

-- الفروع
-- 16. عدد الحسابات في كل فرع
SELECT branch_id, COUNT(*) AS accounts
FROM accounts
GROUP BY branch_id;

-- 17. إجمالي أرصدة كل فرع
SELECT branch_id, SUM(balance) AS total_balance
FROM accounts
GROUP BY branch_id;

-- 18. متوسط رصيد كل فرع
SELECT branch_id, AVG(balance) AS average_balance
FROM accounts
GROUP BY branch_id;

-- البطاقات
-- 19. البطاقات التي ستنتهي خلال 60 يوم
SELECT *
FROM cards
WHERE expiry_date <= CURDATE() + INTERVAL 60 DAY;

-- 20. البطاقات التي لم تستخدم
SELECT c.*
FROM cards c
LEFT JOIN card_transactions ct ON c.id = ct.card_id
WHERE ct.id IS NULL;

-- 21. إجمالي استخدام كل بطاقة
SELECT card_id, SUM(amount) AS total_used
FROM card_transactions
WHERE status = 'approved'
GROUP BY card_id;

-- 22. أكثر Merchant
SELECT merchant_name, COUNT(*) AS purchases
FROM card_transactions
GROUP BY merchant_name
ORDER BY purchases DESC
LIMIT 1;

-- القروض
-- 23. القروض النشطة
SELECT *
FROM loans
WHERE status = 'active';

-- 24. إجمالي القروض لكل عميل
SELECT customer_id, SUM(total_amount) AS total_loans
FROM loans
GROUP BY customer_id;

-- 25. الأقساط المتأخرة
SELECT *
FROM loan_installments
WHERE status = 'overdue';

-- 26. عدد الأقساط المتأخرة لكل عميل
SELECT l.customer_id, COUNT(*) AS overdue
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
WHERE li.status = 'overdue'
GROUP BY l.customer_id;

-- 27. المبلغ المتبقي لكل قرض
SELECT l.loan_number,
       l.total_amount - SUM(li.paid_amount) AS remaining
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
GROUP BY l.id;

-- 28. نسبة الدفع لكل قرض
SELECT l.loan_number,
       SUM(li.paid_amount) / l.total_amount * 100 AS paid_percent
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
GROUP BY l.id;

-- 29. أكثر شهر تم فيه منح قروض
SELECT MONTH(start_date) AS month, COUNT(*) AS loans
FROM loans
GROUP BY MONTH(start_date)
ORDER BY loans DESC
LIMIT 1;

-- 30. إجمالي الفوائد المتوقعة
SELECT SUM(total_amount - principal_amount) AS total_interest
FROM loans;

-- 31. آخر Transaction لكل حساب
SELECT account_id, MAX(created_at) AS last_transaction
FROM transactions
GROUP BY account_id;

-- 32. أول Transaction لكل حساب
SELECT account_id, MIN(created_at) AS first_transaction
FROM transactions
GROUP BY account_id;

-- 33. الحسابات التي لم تتحرك خلال آخر 90 يوم
SELECT account_id, MAX(created_at) AS last_transaction
FROM transactions
GROUP BY account_id
HAVING MAX(created_at) < CURRENT_DATE - INTERVAL 90 DAY;

-- 34. إجمالي التحويلات لكل شهر
SELECT MONTH(created_at) AS month,
       SUM(amount) AS total
FROM transfers
GROUP BY MONTH(created_at);

-- 35. العملاء الذين يحولون لأكثر من 5 حسابات مختلفة
SELECT a.customer_id,
       COUNT(DISTINCT t.to_account_id) AS accounts
FROM accounts a
JOIN transfers t ON a.id = t.from_account_id
GROUP BY a.customer_id
HAVING COUNT(DISTINCT t.to_account_id) > 5;

-- 36. أكثر حساب استقبل تحويلات
SELECT to_account_id, COUNT(*) AS received
FROM transfers
WHERE status = 'completed'
GROUP BY to_account_id
ORDER BY received DESC
LIMIT 1;

-- 37. أكثر حساب أرسل تحويلات
SELECT from_account_id, COUNT(*) AS sent
FROM transfers
WHERE status = 'completed'
GROUP BY from_account_id
ORDER BY sent DESC
LIMIT 1;

-- الفروع
-- 38. الحسابات التي رصيدها أعلى من متوسط فرعها
SELECT a.account_number, a.branch_id, a.balance
FROM accounts a
WHERE a.balance >
(
    SELECT AVG(a2.balance)
    FROM accounts a2
    WHERE a2.branch_id = a.branch_id
);

-- البطاقات
-- 39. العملاء الذين لديهم أكثر من بطاقة
SELECT a.customer_id, COUNT(c.id) AS cards
FROM accounts a
JOIN cards c ON a.id = c.account_id
GROUP BY a.customer_id
HAVING COUNT(c.id) > 1;

-- 40. البطاقات التي تجاوزت daily_limit
SELECT c.id, c.card_number, c.daily_limit,
       SUM(ct.amount) AS total_used
FROM cards c
JOIN card_transactions ct ON c.id = ct.card_id
WHERE ct.status = 'approved'
GROUP BY c.id
HAVING SUM(ct.amount) > c.daily_limit;

-- القروض
-- 41. العملاء الذين لديهم أكثر من 3 أقساط متأخرة
SELECT l.customer_id, COUNT(*) AS overdue
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
WHERE li.status = 'overdue'
GROUP BY l.customer_id
HAVING COUNT(*) > 3;

-- 42. العملاء الذين سددوا جميع قروضهم
SELECT customer_id
FROM loans
GROUP BY customer_id
HAVING SUM(status <> 'paid') = 0;

-- 43. العملاء الذين لديهم قرض بدون أي دفعة
SELECT l.customer_id
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
GROUP BY l.id, l.customer_id
HAVING SUM(li.paid_amount) = 0;

-- 44. إجمالي الفوائد لكل قرض
SELECT loan_number,
       total_amount - principal_amount AS interest
FROM loans;

-- 45. إجمالي الفوائد لجميع القروض
SELECT SUM(total_amount - principal_amount) AS total_interest
FROM loans;

-- 46. القروض حسب الحالة
SELECT status, COUNT(*) AS loan_count
FROM loans
GROUP BY status;

-- 47. الأقساط حسب الحالة
SELECT status, COUNT(*) AS installment_count
FROM loan_installments
GROUP BY status;

-- 48. إجمالي المبالغ المدفوعة لكل قرض
SELECT loan_id, SUM(paid_amount) AS paid
FROM loan_installments
GROUP BY loan_id;

-- 49. القروض التي لم يُدفع منها شيء
SELECT l.loan_number
FROM loans l
JOIN loan_installments li ON l.id = li.loan_id
GROUP BY l.id
HAVING SUM(li.paid_amount) = 0;

-- 50. إجمالي قيمة القروض
SELECT SUM(total_amount) AS total_loans
FROM loans;



/*customer_financial_summary view*/
DROP VIEW IF EXISTS customer_financial_summary;

CREATE VIEW customer_financial_summary AS
SELECT
    c.id AS customer,
    c.customer_number,
    c.full_name,

    COALESCE(a.number_of_accounts, 0) AS number_of_accounts,
    COALESCE(a.total_balance, 0) AS total_balance,

    COALESCE(s.transfers_sent, 0) AS total_transfers_sent,
    COALESCE(s.sent_amount, 0) AS total_sent_amount,

    COALESCE(r.transfers_received, 0) AS total_transfers_received,
    COALESCE(r.received_amount, 0) AS total_received_amount,

    COALESCE(l.total_loans, 0) AS total_loans,
    COALESCE(l.total_loan_amount, 0) AS total_loan_amount,

    t.last_transaction

FROM customers c

LEFT JOIN
(
    SELECT
        customer_id,
        COUNT(*) AS number_of_accounts,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY customer_id
) a
ON c.id = a.customer_id

LEFT JOIN
(
    SELECT
        a.customer_id,
        COUNT(t.id) AS transfers_sent,
        SUM(t.amount) AS sent_amount
    FROM accounts a
    JOIN transfers t
        ON t.from_account_id = a.id
    WHERE t.status = 'completed'
    GROUP BY a.customer_id
) s
ON c.id = s.customer_id

LEFT JOIN
(
    SELECT
        a.customer_id,
        COUNT(t.id) AS transfers_received,
        SUM(t.amount) AS received_amount
    FROM accounts a
    JOIN transfers t
        ON t.to_account_id = a.id
    WHERE t.status = 'completed'
    GROUP BY a.customer_id
) r
ON c.id = r.customer_id

LEFT JOIN
(
    SELECT
        customer_id,
        COUNT(*) AS total_loans,
        SUM(total_amount) AS total_loan_amount
    FROM loans
    GROUP BY customer_id
) l
ON c.id = l.customer_id

LEFT JOIN
(
    SELECT
        a.customer_id,
        MAX(t.created_at) AS last_transaction
    FROM accounts a
    JOIN transactions t
        ON t.account_id = a.id
    GROUP BY a.customer_id
) t
ON c.id = t.customer_id;

/*account_activity_view*/

DROP VIEW IF EXISTS account_activity_view;

CREATE VIEW account_activity_view AS
SELECT
    a.id AS account,
    a.account_number,
    a.customer_id AS customer,
    a.balance,

    COALESCE(
        SUM(
            CASE
                WHEN t.transaction_type = 'deposit'
                THEN t.amount
                ELSE 0
            END
        ), 0
    ) AS deposits,

    COALESCE(
        SUM(
            CASE
                WHEN t.transaction_type = 'withdrawal'
                THEN t.amount
                ELSE 0
            END
        ), 0
    ) AS withdrawals,

    COUNT(t.id) AS transaction_count,
    MAX(t.created_at) AS last_transaction

FROM accounts a
LEFT JOIN transactions t
    ON a.id = t.account_id
GROUP BY
    a.id,
    a.account_number,
    a.customer_id,
    a.balance;



DROP VIEW IF EXISTS loan_status_view;

CREATE VIEW loan_status_view AS
SELECT
    l.id AS loan,
    l.loan_number,
    l.customer_id AS customer,
    l.principal_amount AS principal,
    l.total_amount,

    COALESCE(SUM(li.paid_amount), 0) AS paid_amount,

    l.total_amount
        - COALESCE(SUM(li.paid_amount), 0)
        AS remaining_amount,

    COUNT(li.id) AS total_installments,

    COALESCE(
        SUM(
            CASE
                WHEN li.status = 'overdue'
                THEN 1
                ELSE 0
            END
        ), 0
    ) AS overdue_installments

FROM loans l
LEFT JOIN loan_installments li
    ON l.id = li.loan_id

GROUP BY
    l.id,
    l.loan_number,
    l.customer_id,
    l.principal_amount,
    l.total_amount;




/*deposit_money procedure*/


DROP PROCEDURE IF EXISTS deposit_money;

DELIMITER //

CREATE PROCEDURE deposit_money(
    IN acc_id INT,
    IN money DECIMAL(15,2)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_before DECIMAL(15,2);
    DECLARE v_after DECIMAL(15,2);
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF money <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit amount must be greater than zero';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM accounts
    WHERE id = acc_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;

    START TRANSACTION;

    SELECT balance, status
    INTO v_before, v_status
    FROM accounts
    WHERE id = acc_id
    FOR UPDATE;

    IF v_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account is not active';
    END IF;

    SET v_after = v_before + money;

    UPDATE accounts
    SET balance = v_after
    WHERE id = acc_id;

    INSERT INTO transactions
    (
        account_id,
        transfer_id,
        transaction_type,
        amount,
        balance_before,
        balance_after,
        description,
        status
    )
    VALUES
    (
        acc_id,
        NULL,
        'deposit',
        money,
        v_before,
        v_after,
        'Deposit',
        'completed'
    );

    COMMIT;
END //

DELIMITER ;




/*withdraw_money procedure*/
DROP PROCEDURE IF EXISTS withdraw_money;

DELIMITER //

CREATE PROCEDURE withdraw_money(
    IN acc_id INT,
    IN money DECIMAL(15,2)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_before DECIMAL(15,2);
    DECLARE v_after DECIMAL(15,2);
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF money <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal amount must be greater than zero';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM accounts
    WHERE id = acc_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;

    START TRANSACTION;

    SELECT balance, status
    INTO v_before, v_status
    FROM accounts
    WHERE id = acc_id
    FOR UPDATE;

    IF v_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account is not active';
    END IF;

    IF v_before < money THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    SET v_after = v_before - money;

    UPDATE accounts
    SET balance = v_after
    WHERE id = acc_id;

    INSERT INTO transactions
    (
        account_id,
        transfer_id,
        transaction_type,
        amount,
        balance_before,
        balance_after,
        description,
        status
    )
    VALUES
    (
        acc_id,
        NULL,
        'withdrawal',
        money,
        v_before,
        v_after,
        'Withdrawal',
        'completed'
    );

    COMMIT;
END //

DELIMITER ;



/*pay_loan_installment procedure*/
DROP PROCEDURE IF EXISTS pay_loan_installment;

DELIMITER //

CREATE PROCEDURE pay_loan_installment(
    IN inst_id INT,
    IN money DECIMAL(15,2)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_amount DECIMAL(15,2);
    DECLARE v_paid DECIMAL(15,2);
    DECLARE v_due_date DATE;
    DECLARE v_new_paid DECIMAL(15,2);
    DECLARE v_new_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF money <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM loan_installments
    WHERE id = inst_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment does not exist';
    END IF;

    START TRANSACTION;

    SELECT amount, paid_amount, due_date
    INTO v_amount, v_paid, v_due_date
    FROM loan_installments
    WHERE id = inst_id
    FOR UPDATE;

    IF v_paid >= v_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment is already fully paid';
    END IF;

    IF v_paid + money > v_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment exceeds installment amount';
    END IF;

    SET v_new_paid = v_paid + money;

    IF v_new_paid = v_amount THEN
        SET v_new_status = 'paid';
    ELSEIF v_due_date < CURDATE() THEN
        SET v_new_status = 'overdue';
    ELSE
        SET v_new_status = 'partially_paid';
    END IF;

    UPDATE loan_installments
    SET
        paid_amount = v_new_paid,
        paid_at = NOW(),
        status = v_new_status
    WHERE id = inst_id;

    COMMIT;
END //

DELIMITER ;








/*block_account procedure*/

DELIMITER //

CREATE PROCEDURE block_account(
IN acc_id INT
)
BEGIN

UPDATE accounts
SET status = 'frozen'
WHERE id = acc_id;

END //

DELIMITER ;



/*transfer transaction*/

ALTER TABLE transfers
ADD COLUMN idempotency_key VARCHAR(100) NULL
AFTER reference_number;

ALTER TABLE transfers
ADD CONSTRAINT uq_transfers_idempotency_key
UNIQUE (idempotency_key);



/*Transfer Money Core*/

DROP PROCEDURE IF EXISTS transfer_money_core;

DELIMITER //

CREATE PROCEDURE transfer_money_core(
    IN p_request_id VARCHAR(100),
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2),
    IN p_description VARCHAR(255)
)
main_block:
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_existing_id INT DEFAULT 0;

    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE v_to_balance DECIMAL(15,2);

    DECLARE v_from_currency VARCHAR(3);
    DECLARE v_to_currency VARCHAR(3);

    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status VARCHAR(20);

    DECLARE v_from_after DECIMAL(15,2);
    DECLARE v_to_after DECIMAL(15,2);

    DECLARE v_fee DECIMAL(15,2) DEFAULT 0.00;
    DECLARE v_reference VARCHAR(50);
    DECLARE v_request VARCHAR(100);

    DECLARE v_existing_from INT;
    DECLARE v_existing_to INT;
    DECLARE v_existing_amount DECIMAL(15,2);
    DECLARE v_existing_description VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_from_account = p_to_account THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source and destination accounts must differ';
    END IF;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;

    SET v_request = COALESCE(
        NULLIF(TRIM(p_request_id), ''),
        UUID()
    );

    START TRANSACTION;

    /* =========================================
       IDEMPOTENCY CHECK
       ========================================= */

    SELECT COALESCE(MAX(id), 0)
    INTO v_existing_id
    FROM transfers
    WHERE idempotency_key = v_request;

    IF v_existing_id > 0 THEN

        SELECT
            from_account_id,
            to_account_id,
            amount,
            description
        INTO
            v_existing_from,
            v_existing_to,
            v_existing_amount,
            v_existing_description
        FROM transfers
        WHERE id = v_existing_id;

        IF v_existing_from <> p_from_account
           OR v_existing_to <> p_to_account
           OR v_existing_amount <> p_amount
           OR NOT (v_existing_description <=> p_description)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Idempotency key already belongs to another request';
        END IF;

        COMMIT;

        SELECT
            id AS transfer_id,
            reference_number,
            idempotency_key,
            status,
            'Already processed' AS result
        FROM transfers
        WHERE id = v_existing_id;

    ELSE

        /* =========================================
           CHECK BOTH ACCOUNTS EXIST
           ========================================= */

        SELECT COUNT(*)
        INTO v_count
        FROM accounts
        WHERE id IN (p_from_account, p_to_account);

        IF v_count <> 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'One or both accounts do not exist';
        END IF;

        /* =========================================
           DETERMINISTIC LOCK ORDER
           ========================================= */

        IF p_from_account < p_to_account THEN

            SELECT balance, currency, status
            INTO v_from_balance, v_from_currency, v_from_status
            FROM accounts
            WHERE id = p_from_account
            FOR UPDATE;

            SELECT balance, currency, status
            INTO v_to_balance, v_to_currency, v_to_status
            FROM accounts
            WHERE id = p_to_account
            FOR UPDATE;

        ELSE

            SELECT balance, currency, status
            INTO v_to_balance, v_to_currency, v_to_status
            FROM accounts
            WHERE id = p_to_account
            FOR UPDATE;

            SELECT balance, currency, status
            INTO v_from_balance, v_from_currency, v_from_status
            FROM accounts
            WHERE id = p_from_account
            FOR UPDATE;

        END IF;

        /* =========================================
           VALIDATIONS
           ========================================= */

        IF v_from_status <> 'active' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Source account is not active';
        END IF;

        IF v_to_status <> 'active' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Destination account is not active';
        END IF;

        IF v_from_currency <> v_to_currency THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Currency mismatch: conversion is not configured';
        END IF;

        IF v_from_balance < p_amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;

        /* No transfer limit exists in current schema. */

        SET v_from_after = v_from_balance - p_amount;
        SET v_to_after = v_to_balance + p_amount;

        SET v_reference =
            CONCAT(
                'TR-',
                REPLACE(UUID(), '-', '')
            );

        /* =========================================
           CREATE TRANSFER
           ========================================= */

        INSERT INTO transfers
        (
            reference_number,
            idempotency_key,
            from_account_id,
            to_account_id,
            amount,
            transfer_fee,
            description,
            created_at,
            status
        )
        VALUES
        (
            v_reference,
            v_request,
            p_from_account,
            p_to_account,
            p_amount,
            v_fee,
            p_description,
            NOW(),
            'processing'
        );

        /* =========================================
           UPDATE BALANCES
           ========================================= */

        UPDATE accounts
        SET balance = v_from_after
        WHERE id = p_from_account;

        UPDATE accounts
        SET balance = v_to_after
        WHERE id = p_to_account;

        /* =========================================
           TRANSFER OUT
           ========================================= */

        INSERT INTO transactions
        (
            account_id,
            transfer_id,
            transaction_type,
            amount,
            balance_before,
            balance_after,
            description,
            created_at,
            status
        )
        VALUES
        (
            p_from_account,
            LAST_INSERT_ID(),
            'transfer_out',
            p_amount,
            v_from_balance,
            v_from_after,
            COALESCE(p_description, 'Transfer out'),
            NOW(),
            'completed'
        );

        /* =========================================
           TRANSFER IN
           ========================================= */

        INSERT INTO transactions
        (
            account_id,
            transfer_id,
            transaction_type,
            amount,
            balance_before,
            balance_after,
            description,
            created_at,
            status
        )
        SELECT
            p_to_account,
            id,
            'transfer_in',
            p_amount,
            v_to_balance,
            v_to_after,
            COALESCE(p_description, 'Transfer in'),
            NOW(),
            'completed'
        FROM transfers
        WHERE reference_number = v_reference;

        /* =========================================
           FEE, IF THERE IS ONE
           ========================================= */

        IF v_fee > 0 THEN

            INSERT INTO transactions
            (
                account_id,
                transfer_id,
                transaction_type,
                amount,
                balance_before,
                balance_after,
                description,
                created_at,
                status
            )
            VALUES
            (
                p_from_account,
                (
                    SELECT id
                    FROM transfers
                    WHERE reference_number = v_reference
                ),
                'fee',
                v_fee,
                v_from_after,
                v_from_after - v_fee,
                'Transfer fee',
                NOW(),
                'completed'
            );

            UPDATE accounts
            SET balance = balance - v_fee
            WHERE id = p_from_account;

        END IF;

        /* =========================================
           COMPLETE TRANSFER
           ========================================= */

        UPDATE transfers
        SET
            status = 'completed',
            completed_at = NOW()
        WHERE reference_number = v_reference;

        COMMIT;

        SELECT
            id AS transfer_id,
            reference_number,
            idempotency_key,
            status,
            'Transfer completed' AS result
        FROM transfers
        WHERE reference_number = v_reference;

    END IF;

END //

DELIMITER ;

-- ====================================
/*Transfer Money*/


DROP PROCEDURE IF EXISTS transfer_money;

DELIMITER //

CREATE PROCEDURE transfer_money(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2),
    IN p_description VARCHAR(255)
)
BEGIN

    CALL transfer_money_core(
        UUID(),
        p_from_account,
        p_to_account,
        p_amount,
        p_description
    );

END //


DELIMITER ;

-- ====================================
/*Network-safe Idempotent Transfer*/

DROP PROCEDURE IF EXISTS transfer_money_request;

DELIMITER //

CREATE PROCEDURE transfer_money_request(
    IN p_request_id VARCHAR(100),
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2),
    IN p_description VARCHAR(255)
)
BEGIN

    IF p_request_id IS NULL
       OR TRIM(p_request_id) = ''
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Request ID is required';
    END IF;

    CALL transfer_money_core(
        p_request_id,
        p_from_account,
        p_to_account,
        p_amount,
        p_description
    );

END //

DELIMITER ;

-- ====================================
/*Double Execution Challenge*/

SELECT
    id,
    reference_number,
    idempotency_key,
    from_account_id,
    to_account_id,
    amount,
    status
FROM transfers
WHERE idempotency_key = 'REQ-10001';

-- ====================================

SELECT
    t.id,
    t.transfer_id,
    t.account_id,
    t.transaction_type,
    t.amount,
    t.balance_before,
    t.balance_after
FROM transactions t
JOIN transfers tr
    ON tr.id = t.transfer_id
WHERE tr.idempotency_key = 'REQ-10001';

-- ====================================
/*Concurrency Challenge*/

SELECT balance FROM accounts;

-- ====================================

UPDATE accounts
SET balance = balance - 800
WHERE id = 1
AND balance >= 800;

-- ====================================

UPDATE accounts
SET balance = balance - 700
WHERE id = 1
AND balance >= 700;

-- ====================================
/*Balance Integrity*/

WITH ordered_transactions AS
(
    SELECT
        t.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY t.account_id
            ORDER BY t.created_at, t.id
        ) AS rn,

        CASE
            WHEN t.transaction_type IN
            (
                'deposit',
                'transfer_in',
                'refund'
            )
            THEN t.amount

            WHEN t.transaction_type IN
            (
                'withdrawal',
                'transfer_out',
                'fee',
                'loan_payment'
            )
            THEN -t.amount

            ELSE 0
        END AS signed_amount

    FROM transactions t
    WHERE t.status = 'completed'
),

calculated AS
(
    SELECT
        account_id,

        MAX(
            CASE
                WHEN rn = 1
                THEN balance_before
            END
        ) AS opening_balance,

        SUM(signed_amount) AS net_change,

        MAX(
            CASE
                WHEN rn = 1
                THEN balance_before
            END
        ) + SUM(signed_amount)
        AS calculated_balance

    FROM ordered_transactions
    GROUP BY account_id
)

SELECT
    a.id AS account_id,
    a.account_number,
    a.balance AS stored_balance,
    c.opening_balance,
    c.net_change,
    c.calculated_balance,

    a.balance - c.calculated_balance
    AS difference

FROM accounts a
JOIN calculated c
    ON c.account_id = a.id

WHERE a.balance <> c.calculated_balance

ORDER BY ABS(a.balance - c.calculated_balance) DESC; 

-- ====================================
/*Balance Integrity - control*/

WITH ordered AS
(
    SELECT
        t.*,

        LEAD(balance_before) OVER
        (
            PARTITION BY account_id
            ORDER BY created_at, id
        ) AS next_balance_before

    FROM transactions t
)

SELECT
    id,
    account_id,
    balance_after,
    next_balance_before

FROM ordered

WHERE next_balance_before IS NOT NULL
  AND balance_after <> next_balance_before;

-- ====================================
/*Window Functions*/

SELECT
    c.id,
    c.full_name,
    SUM(a.balance) AS total_balance,

    ROW_NUMBER() OVER
    (
        ORDER BY SUM(a.balance) DESC
    ) AS row_number_rank,

    RANK() OVER
    (
        ORDER BY SUM(a.balance) DESC
    ) AS rank_position,

    DENSE_RANK() OVER
    (
        ORDER BY SUM(a.balance) DESC
    ) AS dense_rank_position

FROM customers c
JOIN accounts a
    ON c.id = a.customer_id

GROUP BY c.id, c.full_name;

-- ====================================

SELECT
    a.branch_id,
    a.account_number,
    a.balance,

    ROW_NUMBER() OVER
    (
        PARTITION BY a.branch_id
        ORDER BY a.balance DESC
    ) AS row_number_position,

    RANK() OVER
    (
        PARTITION BY a.branch_id
        ORDER BY a.balance DESC
    ) AS rank_position,

    DENSE_RANK() OVER
    (
        PARTITION BY a.branch_id
        ORDER BY a.balance DESC
    ) AS dense_rank_position

FROM accounts a;

-- ====================================
/*her branchte Top 3 account */

WITH ranked_accounts AS
(
    SELECT
        a.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY branch_id
            ORDER BY balance DESC
        ) AS rn

    FROM accounts a
)

SELECT
    id,
    account_number,
    branch_id,
    balance

FROM ranked_accounts

WHERE rn <= 3

ORDER BY branch_id, balance DESC;

-- ====================================
/*transaction sıralama*/

SELECT
    account_id,
    id,
    transaction_type,
    amount,
    created_at,

    ROW_NUMBER() OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    ) AS transaction_number

FROM transactions;

-- ====================================
/*previous transaction*/

SELECT
    account_id,
    id,
    transaction_type,
    amount,
    created_at,

    LAG(amount) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    ) AS previous_amount

FROM transactions;

-- ====================================
/*Next transaction*/

SELECT
    account_id,
    id,
    transaction_type,
    amount,
    created_at,

    LEAD(amount) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    ) AS next_amount

FROM transactions;

-- ====================================
/*balance farkı*/

SELECT
    account_id,
    id,
    created_at,
    balance_after,

    LAG(balance_after) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    ) AS previous_balance_after,

    balance_after
    -
    LAG(balance_after) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    ) AS balance_difference

FROM transactions

ORDER BY account_id, created_at, id;

-- ====================================
/*running balance*/

WITH tx AS
(
    SELECT
        t.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY account_id
            ORDER BY created_at, id
        ) AS rn,

        CASE
            WHEN transaction_type IN
            ('deposit', 'transfer_in', 'refund')
                THEN amount

            WHEN transaction_type IN
            ('withdrawal', 'transfer_out', 'fee', 'loan_payment')
                THEN -amount

            ELSE 0
        END AS signed_amount

    FROM transactions t
    WHERE status = 'completed'
)

SELECT
    account_id,
    id,
    transaction_type,
    amount,
    created_at,

    FIRST_VALUE(balance_before) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
    )
    +

    SUM(signed_amount) OVER
    (
        PARTITION BY account_id
        ORDER BY created_at, id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    )
    AS running_balance

FROM tx

ORDER BY account_id, created_at, id;

-- ====================================
/*Monthly running total transfers*/

WITH monthly_transfers AS
(
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS transfer_month,
        SUM(amount) AS monthly_total

    FROM transfers

    WHERE status = 'completed'

    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
)

SELECT
    transfer_month,
    monthly_total,

    SUM(monthly_total) OVER
    (
        ORDER BY transfer_month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_total

FROM monthly_transfers

ORDER BY transfer_month;

-- ====================================
/*bu ay ile önceki ayı karşılaştırma */

WITH monthly_transfers AS
(
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS transfer_month,
        SUM(amount) AS monthly_total

    FROM transfers

    WHERE status = 'completed'

    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
)

SELECT
    transfer_month,
    monthly_total,

    SUM(monthly_total) OVER
    (
        ORDER BY transfer_month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_total

FROM monthly_transfers

ORDER BY transfer_month;

-- ====================================
/*müşterinin transfer katkısı*/

WITH customer_transfers AS
(
    SELECT
        a.customer_id,
        SUM(t.amount) AS sent_amount

    FROM accounts a

    JOIN transfers t
        ON t.from_account_id = a.id

    WHERE t.status = 'completed'

    GROUP BY a.customer_id
)

SELECT
    customer_id,
    sent_amount,

    ROUND(
        100 * sent_amount /
        NULLIF(SUM(sent_amount) OVER (), 0),
        2
    ) AS contribution_percent

FROM customer_transfers

ORDER BY contribution_percent DESC;

-- ====================================
/*CTE*/

WITH customer_balances AS
(
    SELECT
        c.id,
        c.full_name,
        COALESCE(SUM(a.balance), 0) AS total_balance

    FROM customers c

    LEFT JOIN accounts a
        ON c.id = a.customer_id

    GROUP BY c.id, c.full_name
),

average_balance AS
(
    SELECT AVG(total_balance) AS avg_balance
    FROM customer_balances
)

SELECT
    cb.id,
    cb.full_name,
    cb.total_balance,
    ab.avg_balance

FROM customer_balances cb
CROSS JOIN average_balance ab

WHERE cb.total_balance > ab.avg_balance; 

-- ====================================
/*CTE - account activity*/

WITH account_activity AS
(
    SELECT
        a.id AS account_id,
        a.account_number,
        a.customer_id,

        COUNT(t.id) AS transaction_count,

        COALESCE(SUM(t.amount), 0) AS transaction_value,

        MAX(t.created_at) AS last_transaction

    FROM accounts a

    LEFT JOIN transactions t
        ON a.id = t.account_id

    GROUP BY
        a.id,
        a.account_number,
        a.customer_id
)

SELECT *
FROM account_activity

ORDER BY transaction_count DESC;

-- ====================================
/*En aktif müşteriler*/

WITH customer_activity AS
(
    SELECT
        c.id,
        c.full_name,
        COUNT(t.id) AS transaction_count

    FROM customers c

    LEFT JOIN accounts a
        ON c.id = a.customer_id

    LEFT JOIN transactions t
        ON a.id = t.account_id

    GROUP BY c.id, c.full_name
)

SELECT *
FROM customer_activity

ORDER BY transaction_count DESC
LIMIT 10;

-- ====================================
/*Overdue installment analysis*/

WITH overdue AS
(
    SELECT
        l.customer_id,
        l.loan_number,
        li.id AS installment_id,
        li.amount,
        li.paid_amount,
        li.due_date

    FROM loans l

    JOIN loan_installments li
        ON l.id = li.loan_id

    WHERE li.status = 'overdue'
)

SELECT
    customer_id,
    COUNT(*) AS overdue_count,
    SUM(amount - paid_amount) AS overdue_amount

FROM overdue

GROUP BY customer_id

ORDER BY overdue_amount DESC;

-- ====================================
/*Branch performance*/

WITH branch_accounts AS
(
    SELECT
        branch_id,
        COUNT(*) AS account_count,
        SUM(balance) AS total_balance,
        AVG(balance) AS average_balance

    FROM accounts

    GROUP BY branch_id
),

branch_transactions AS
(
    SELECT
        a.branch_id,
        COUNT(t.id) AS transaction_count,
        COALESCE(SUM(t.amount), 0) AS transaction_volume

    FROM accounts a

    LEFT JOIN transactions t
        ON a.id = t.account_id

    GROUP BY a.branch_id
)

SELECT
    b.id AS branch_id,
    b.branch_name,

    COALESCE(ba.account_count, 0) AS account_count,
    COALESCE(ba.total_balance, 0) AS total_balance,
    COALESCE(ba.average_balance, 0) AS average_balance,

    COALESCE(bt.transaction_count, 0) AS transaction_count,
    COALESCE(bt.transaction_volume, 0) AS transaction_volume

FROM branches b

LEFT JOIN branch_accounts ba
    ON b.id = ba.branch_id

LEFT JOIN branch_transactions bt
    ON b.id = bt.branch_id

ORDER BY transaction_volume DESC;

-- ====================================
/*Şüpheli balance hesapları*/

WITH calculated AS
(
    SELECT
        account_id,

        MAX(
            CASE
                WHEN rn = 1
                THEN balance_before
            END
        ) AS opening_balance,

        SUM(signed_amount) AS net_change

    FROM
    (
        SELECT
            t.*,

            ROW_NUMBER() OVER
            (
                PARTITION BY account_id
                ORDER BY created_at, id
            ) AS rn,

            CASE
                WHEN transaction_type IN
                ('deposit', 'transfer_in', 'refund')
                    THEN amount

                WHEN transaction_type IN
                ('withdrawal', 'transfer_out', 'fee', 'loan_payment')
                    THEN -amount

                ELSE 0
            END AS signed_amount

        FROM transactions t

        WHERE status = 'completed'
    ) x

    GROUP BY account_id
)

SELECT
    a.id,
    a.account_number,
    a.balance AS stored_balance,

    c.opening_balance + c.net_change
    AS calculated_balance,

    a.balance -
    (c.opening_balance + c.net_change)
    AS difference

FROM accounts a

JOIN calculated c
    ON a.id = c.account_id

WHERE a.balance <>
      (c.opening_balance + c.net_change);

-- ====================================
/*trigers*/

DROP TRIGGER IF EXISTS trg_transactions_before_insert;
DROP TRIGGER IF EXISTS trg_transactions_before_delete;
DROP TRIGGER IF EXISTS trg_transactions_before_update;
DROP TRIGGER IF EXISTS trg_accounts_before_delete;
DROP TRIGGER IF EXISTS trg_accounts_after_update;
DROP TRIGGER IF EXISTS trg_customers_after_update;
DROP TRIGGER IF EXISTS trg_transfers_after_insert;
DROP TRIGGER IF EXISTS trg_transfers_after_update;
DROP TRIGGER IF EXISTS trg_loans_after_update;
DROP TRIGGER IF EXISTS trg_installments_before_update;
DROP TRIGGER IF EXISTS trg_installments_after_update;

-- ====================================

DELIMITER //

CREATE TRIGGER trg_transactions_before_insert
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN

    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Financial transaction amount must be greater than zero';
    END IF;

END //

DELIMITER ;

-- ====================================
/*Completed transaction remove*/

DELIMITER //

CREATE TRIGGER trg_transactions_before_delete
BEFORE DELETE ON transactions
FOR EACH ROW
BEGIN

    IF OLD.status = 'completed' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Completed financial transactions cannot be deleted';

    END IF;

END //

DELIMITER ;

-- ====================================
/*acount silme koruması*/

DELIMITER //

CREATE TRIGGER trg_accounts_before_delete
BEFORE DELETE ON accounts
FOR EACH ROW
BEGIN
    DECLARE v_transactions INT DEFAULT 0;
    DECLARE v_transfers INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_transactions
    FROM transactions
    WHERE account_id = OLD.id;

    SELECT COUNT(*)
    INTO v_transfers
    FROM transfers
    WHERE from_account_id = OLD.id
       OR to_account_id = OLD.id;

    IF v_transactions > 0
       OR v_transfers > 0
    THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Account with financial history cannot be deleted';

    END IF;

END //

DELIMITER ;

-- ====================================
/*Balance before/after değiştirmeyi engelle*/

DELIMITER //

CREATE TRIGGER trg_transactions_before_update
BEFORE UPDATE ON transactions
FOR EACH ROW
BEGIN

    IF OLD.status = 'completed'
       AND (
            NEW.balance_before <> OLD.balance_before
            OR
            NEW.balance_after <> OLD.balance_after
       )
    THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Balance history of completed transaction is immutable';

    END IF;

END //

DELIMITER ;

-- ====================================
/*acount değişikleri "audit_log"a yazılsın*/

DELIMITER //

CREATE TRIGGER trg_accounts_after_update
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN

    IF OLD.balance <> NEW.balance THEN

        INSERT INTO audit_logs
        (
            customer_id,
            account_id,
            action_type,
            table_name,
            record_id,
            old_value,
            new_value
        )
        VALUES
        (
            NEW.customer_id,
            NEW.id,
            'UPDATE',
            'accounts',
            NEW.id,
            CONCAT('balance=', OLD.balance),
            CONCAT('balance=', NEW.balance)
        );

    END IF;

    IF OLD.status <> NEW.status THEN

        INSERT INTO audit_logs
        (
            customer_id,
            account_id,
            action_type,
            table_name,
            record_id,
            old_value,
            new_value
        )
        VALUES
        (
            NEW.customer_id,
            NEW.id,
            'UPDATE',
            'accounts',
            NEW.id,
            CONCAT('status=', OLD.status),
            CONCAT('status=', NEW.status)
        );

    END IF;

END //

DELIMITER ;

-- ====================================
/*costumer değişikliğini audit et*/

DELIMITER //

CREATE TRIGGER trg_customers_after_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN

    IF NOT (OLD.status <=> NEW.status) THEN

        INSERT INTO audit_logs
        (
            customer_id,
            action_type,
            table_name,
            record_id,
            old_value,
            new_value
        )
        VALUES
        (
            NEW.id,
            'UPDATE',
            'customers',
            NEW.id,
            CONCAT('status=', OLD.status),
            CONCAT('status=', NEW.status)
        );

    END IF;

    IF NOT (OLD.email <=> NEW.email) THEN

        INSERT INTO audit_logs
        (
            customer_id,
            action_type,
            table_name,
            record_id,
            old_value,
            new_value
        )
        VALUES
        (
            NEW.id,
            'UPDATE',
            'customers',
            NEW.id,
            CONCAT('email=', OLD.email),
            CONCAT('email=', NEW.email)
        );

    END IF;

END //

DELIMITER ;

-- ====================================
/*Transfer audit*/

DELIMITER //

CREATE TRIGGER trg_transfers_after_insert
AFTER INSERT ON transfers
FOR EACH ROW
BEGIN

    INSERT INTO audit_logs
    (
        account_id,
        action_type,
        table_name,
        record_id,
        old_value,
        new_value
    )
    VALUES
    (
        NEW.from_account_id,
        'CREATE',
        'transfers',
        NEW.id,
        NULL,
        CONCAT(
            'Transfer created: ',
            NEW.reference_number,
            ', amount=',
            NEW.amount
        )
    );

END //

DELIMITER ;

-- ====================================
/*Installment status trigger*/

DELIMITER //

CREATE TRIGGER trg_installments_before_update
BEFORE UPDATE ON loan_installments
FOR EACH ROW
BEGIN

    IF NEW.paid_amount >= NEW.amount THEN

        SET NEW.paid_amount = NEW.amount;
        SET NEW.status = 'paid';

        IF NEW.paid_at IS NULL THEN
            SET NEW.paid_at = NOW();
        END IF;

    ELSEIF NEW.paid_amount > 0 THEN

        SET NEW.status = 'partially_paid';

    ELSEIF NEW.due_date < CURDATE() THEN

        SET NEW.status = 'overdue';

    ELSE

        SET NEW.status = 'pending';

    END IF;

END //

DELIMITER ;

-- ====================================
/*Tüm installment'lar ödendiyse Loan = paid*/

DELIMITER //

CREATE TRIGGER trg_installments_after_update
AFTER UPDATE ON loan_installments
FOR EACH ROW
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_paid INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_total
    FROM loan_installments
    WHERE loan_id = NEW.loan_id;

    SELECT COUNT(*)
    INTO v_paid
    FROM loan_installments
    WHERE loan_id = NEW.loan_id
      AND status = 'paid';

    IF v_total > 0 AND v_total = v_paid THEN

        UPDATE loans
        SET status = 'paid'
        WHERE id = NEW.loan_id
          AND status <> 'cancelled';

    END IF;

END //

DELIMITER ;

-- ====================================
/*Loan status audit*/

DELIMITER //

CREATE TRIGGER trg_loans_after_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

        INSERT INTO audit_logs
        (
            customer_id,
            action_type,
            table_name,
            record_id,
            old_value,
            new_value
        )
        VALUES
        (
            NEW.customer_id,
            'UPDATE',
            'loans',
            NEW.id,
            CONCAT('status=', OLD.status),
            CONCAT('status=', NEW.status)
        );

    END IF;

END //

DELIMITER ;

-- ====================================
/*Fraud Detection*/

SELECT
    t1.from_account_id AS account_id,
    t1.created_at AS window_start,
    COUNT(t2.id) AS transfer_count

FROM transfers t1

JOIN transfers t2
    ON t2.from_account_id = t1.from_account_id
    AND t2.status = 'completed'
    AND t2.created_at BETWEEN
        t1.created_at
        AND DATE_ADD(t1.created_at, INTERVAL 1 HOUR)

WHERE t1.status = 'completed'

GROUP BY
    t1.from_account_id,
    t1.created_at

HAVING COUNT(t2.id) > 10

ORDER BY transfer_count DESC;

-- ====================================
/*Suspicious Transfer Frequency*/

SELECT
    t1.from_account_id AS account_id,
    t1.created_at AS window_start,
    COUNT(t2.id) AS transfer_count

FROM transfers t1

JOIN transfers t2
    ON t2.from_account_id = t1.from_account_id
    AND t2.status = 'completed'
    AND t2.created_at BETWEEN
        t1.created_at
        AND DATE_ADD(t1.created_at, INTERVAL 1 HOUR)

WHERE t1.status = 'completed'

GROUP BY
    t1.from_account_id,
    t1.created_at

HAVING COUNT(t2.id) > 10

ORDER BY transfer_count DESC;

-- ====================================
/*Multiple Senders to One Account*/

SELECT
    to_account_id,
    DATE(created_at) AS transfer_date,
    COUNT(DISTINCT from_account_id) AS unique_senders,
    SUM(amount) AS received_amount

FROM transfers

WHERE status = 'completed'

GROUP BY
    to_account_id,
    DATE(created_at)

HAVING COUNT(DISTINCT from_account_id) > 15

ORDER BY unique_senders DESC;

-- ====================================
/*Unusually Large Transfer*/

WITH customer_average AS
(
    SELECT
        a.customer_id,
        AVG(t.amount) AS average_transfer

    FROM accounts a

    JOIN transfers t
        ON a.id = t.from_account_id

    WHERE t.status = 'completed'

    GROUP BY a.customer_id
)

SELECT
    t.id,
    t.reference_number,
    a.customer_id,
    t.amount,
    ca.average_transfer

FROM transfers t

JOIN accounts a
    ON t.from_account_id = a.id

JOIN customer_average ca
    ON a.customer_id = ca.customer_id

WHERE t.status = 'completed'
  AND t.amount > 3 * ca.average_transfer;

-- ====================================
/*90 gün pasif kaldıktan sonra büyük transfer*/

WITH previous_activity AS
(
    SELECT
        t.id,
        t.from_account_id,
        t.amount,
        t.created_at,

        (
            SELECT MAX(t2.created_at)
            FROM transactions t2
            WHERE t2.account_id = t.from_account_id
              AND t2.created_at < t.created_at
              AND t2.status = 'completed'
        ) AS last_activity

    FROM transfers t

    WHERE t.status = 'completed'
)

SELECT
    id,
    from_account_id,
    amount,
    created_at,
    last_activity,
    DATEDIFF(created_at, last_activity) AS inactive_days

FROM previous_activity

WHERE last_activity IS NOT NULL
  AND DATEDIFF(created_at, last_activity) >= 90

  AND amount >
      (
          SELECT AVG(t3.amount) * 3
          FROM transfers t3
          WHERE t3.from_account_id =
                previous_activity.from_account_id
            AND t3.status = 'completed'
      );

-- ====================================
/*Kısa sürede birçok card transaction*/

SELECT
    c1.card_id,
    c1.transaction_date AS window_start,
    COUNT(c2.id) AS transaction_count

FROM card_transactions c1

JOIN card_transactions c2
    ON c2.card_id = c1.card_id
    AND c2.transaction_date BETWEEN
        c1.transaction_date
        AND DATE_ADD(c1.transaction_date, INTERVAL 10 MINUTE)

GROUP BY
    c1.card_id,
    c1.transaction_date

HAVING COUNT(c2.id) >= 4;

-- ====================================
/*Kısa sürede farklı merchant'lar*/

 SELECT
    c1.card_id,
    c1.transaction_date,
    COUNT(DISTINCT c2.merchant_name) AS merchant_count
FROM card_transactions c1
JOIN card_transactions c2
    ON c2.card_id = c1.card_id
    AND c2.transaction_date BETWEEN
        c1.transaction_date
        AND DATE_ADD(c1.transaction_date, INTERVAL 30 MINUTE)
GROUP BY
    c1.card_id,
    c1.transaction_date
HAVING COUNT(DISTINCT c2.merchant_name) >= 3;


-- ====================================
/*refund orjinal işlemden büyüktür*/

ALTER TABLE transactions
ADD COLUMN original_transaction_id INT NULL
AFTER transfer_id;

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_original
FOREIGN KEY (original_transaction_id)
REFERENCES transactions(id);

-- ====================================

SELECT
    refund.id AS refund_id,
    refund.amount AS refund_amount,
    original.id AS original_id,
    original.amount AS original_amount

FROM transactions refund

JOIN transactions original
    ON refund.original_transaction_id = original.id

WHERE refund.transaction_type = 'refund'
  AND refund.amount > original.amount;

-- ====================================
/*İNDEXSİNG*/

CREATE INDEX idx_accounts_customer_balance
ON accounts(customer_id, balance);

CREATE INDEX idx_transfers_status_created
ON transfers(status, created_at);

CREATE INDEX idx_transfers_from_created
ON transfers(from_account_id, created_at);

CREATE INDEX idx_transfers_to_created
ON transfers(to_account_id, created_at);

CREATE INDEX idx_transactions_account_created
ON transactions(account_id, created_at, id);

CREATE INDEX idx_transactions_type_created
ON transactions(transaction_type, created_at);

CREATE INDEX idx_loans_status_start
ON loans(status, start_date);

CREATE INDEX idx_installments_status_due
ON loan_installments(status, due_date);

CREATE INDEX idx_card_transactions_card_date
ON card_transactions(card_id, transaction_date);

-- ====================================
/*EXPLAIN Before*/

EXPLAIN
SELECT *
FROM transfers
WHERE status = 'completed'
  AND created_at >= '2024-01-01'
  AND created_at < '2024-02-01';

-- ====================================


EXPLAIN
SELECT *
FROM transactions
WHERE account_id = 1
ORDER BY created_at DESC;



-- ====================================
/*Isolation Levels*/

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

UPDATE accounts
SET balance = balance - 500
WHERE id = 1;

-- لا تعمل COMMIT هنا
-- انتقل إلى SESSION B

-- ====================================

/*
SESSION B
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

SELECT balance
FROM accounts
WHERE id = 1;

COMMIT;

-- SESSION B يستطيع قراءة القيمة غير الملتزم بها
-- ارجع إلى SESSION A

-- ====================================

/*
SESSION A
*/
COMMIT;

-- ====================================
/*read commited ile dirty Read*/

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT balance
FROM accounts
WHERE id = 1;

-- ====================================
-- non-repeatable read

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT balance
FROM accounts
WHERE id = 1;

-- ====================================

/*
SESSION B
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

UPDATE accounts
SET balance = balance + 500
WHERE id = 1;

COMMIT;

-- ====================================

/*
SESSION A

SELECT مرة ثانية بعد COMMIT الخاص بـ SESSION B
*/
SELECT balance
FROM accounts
WHERE id = 1;

COMMIT;

-- ====================================
/*REPEATABLE READ*/

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

SELECT balance
FROM accounts
WHERE id = 1;

-- ====================================

/*
SESSION B
*/
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

UPDATE accounts
SET balance = balance + 500
WHERE id = 1;

COMMIT;

-- ====================================

/*
SESSION A

SELECT مرة ثانية
*/
SELECT balance
FROM accounts
WHERE id = 1;

COMMIT;

-- ====================================
/*phantom read*/

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT *
FROM transactions
WHERE amount > 5000;

-- ====================================

/*
SESSION B
*/
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

INSERT INTO transactions
(
    account_id,
    transaction_type,
    amount,
    balance_before,
    balance_after,
    description,
    status
)
VALUES
(
    1,
    'deposit',
    9000,
    10000,
    19000,
    'Phantom test',
    'completed'
);

COMMIT;

-- ====================================

/*
SESSION A

SELECT مرة ثانية لإظهار Phantom Read
*/
SELECT *
FROM transactions
WHERE amount > 5000;

COMMIT;

-- ====================================
/*serializable*/

/*
SESSION A
*/
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

SELECT *
FROM transactions
WHERE amount > 5000;

-- ====================================

/*
SESSION B
*/

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

INSERT INTO transactions
(
    account_id,
    transaction_type,
    amount,
    balance_before,
    balance_after,
    description,
    status
)
VALUES
(
    1,
    'deposit',
    9000,
    10000,
    19000,
    'Phantom test',
    'completed'
);

COMMIT;

-- ====================================

/*
SESSION A
*/
COMMIT;

-- ====================================

START TRANSACTION;

SELECT balance
FROM accounts
WHERE id = 1
FOR UPDATE;

UPDATE accounts
SET balance = balance - 100
WHERE id = 1;

COMMIT;

-- ====================================
/*FINAL REPORT */

WITH account_summary AS
(
    SELECT
        customer_id,
        COUNT(*) AS number_of_accounts,
        COALESCE(SUM(balance), 0) AS total_balance
    FROM accounts
    GROUP BY customer_id
),

sent_summary AS
(
    SELECT
        a.customer_id,
        COUNT(t.id) AS transfers_sent,
        COALESCE(SUM(t.amount), 0) AS sent_amount
    FROM accounts a
    JOIN transfers t
        ON t.from_account_id = a.id
    WHERE t.status = 'completed'
    GROUP BY a.customer_id
),

received_summary AS
(
    SELECT
        a.customer_id,
        COUNT(t.id) AS transfers_received,
        COALESCE(SUM(t.amount), 0) AS received_amount
    FROM accounts a
    JOIN transfers t
        ON t.to_account_id = a.id
    WHERE t.status = 'completed'
    GROUP BY a.customer_id
),

card_summary AS
(
    SELECT
        a.customer_id,
        COUNT(DISTINCT c.id) AS number_of_cards,
        COALESCE(
            SUM(
                CASE
                    WHEN ct.status = 'approved'
                    THEN ct.amount
                    ELSE 0
                END
            ),
            0
        ) AS card_spending
    FROM accounts a
    LEFT JOIN cards c
        ON a.id = c.account_id
    LEFT JOIN card_transactions ct
        ON c.id = ct.card_id
    GROUP BY a.customer_id
),

loan_summary AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_loans,
        COALESCE(SUM(principal_amount), 0) AS total_borrowed,
        COALESCE(SUM(total_amount), 0) AS total_loan_value
    FROM loans
    GROUP BY customer_id
),

loan_payment_summary AS
(
    SELECT
        l.customer_id,
        COALESCE(SUM(li.paid_amount), 0) AS total_loan_paid,

        COALESCE(
            SUM(
                CASE
                    WHEN li.status = 'overdue'
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ) AS overdue_installments

    FROM loans l

    LEFT JOIN loan_installments li
        ON l.id = li.loan_id

    GROUP BY l.customer_id
),

transaction_summary AS
(
    SELECT
        a.customer_id,
        MAX(t.created_at) AS last_transaction_date

    FROM accounts a

    LEFT JOIN transactions t
        ON a.id = t.account_id

    GROUP BY a.customer_id
),

account_usage_base AS
(
    SELECT
        a.customer_id,
        a.id AS account_id,
        a.account_number,
        COUNT(t.id) AS transaction_count

    FROM accounts a

    LEFT JOIN transactions t
        ON a.id = t.account_id

    GROUP BY
        a.customer_id,
        a.id,
        a.account_number
),

account_usage_ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY transaction_count DESC, account_id
        ) AS rn

    FROM account_usage_base
),

most_used_account AS
(
    SELECT
        customer_id,
        account_number
    FROM account_usage_ranked
    WHERE rn = 1
)

SELECT
    c.customer_number,
    c.full_name AS customer_name,

    COALESCE(a.number_of_accounts, 0)
        AS number_of_accounts,

    COALESCE(a.total_balance, 0)
        AS total_balance,

    COALESCE(
        (
            SELECT SUM(t.amount)
            FROM transactions t
            JOIN accounts acc
                ON t.account_id = acc.id
            WHERE acc.customer_id = c.id
              AND t.transaction_type = 'deposit'
              AND t.status = 'completed'
        ),
        0
    ) AS total_deposits,

    COALESCE(
        (
            SELECT SUM(t.amount)
            FROM transactions t
            JOIN accounts acc
                ON t.account_id = acc.id
            WHERE acc.customer_id = c.id
              AND t.transaction_type = 'withdrawal'
              AND t.status = 'completed'
        ),
        0
    ) AS total_withdrawals,

    COALESCE(s.transfers_sent, 0)
        AS transfers_sent,

    COALESCE(s.sent_amount, 0)
        AS sent_amount,

    COALESCE(r.transfers_received, 0)
        AS transfers_received,

    COALESCE(r.received_amount, 0)
        AS received_amount,

    COALESCE(cs.number_of_cards, 0)
        AS number_of_cards,

    COALESCE(cs.card_spending, 0)
        AS card_spending,

    COALESCE(ls.total_loans, 0)
        AS total_loans,

    COALESCE(ls.total_borrowed, 0)
        AS total_borrowed,

    COALESCE(lp.total_loan_paid, 0)
        AS total_loan_paid,

    COALESCE(ls.total_loan_value, 0)
        - COALESCE(lp.total_loan_paid, 0)
        AS remaining_debt,

    COALESCE(lp.overdue_installments, 0)
        AS overdue_installments,

    ts.last_transaction_date,

    mua.account_number
        AS most_used_account

FROM customers c

LEFT JOIN account_summary a
    ON c.id = a.customer_id

LEFT JOIN sent_summary s
    ON c.id = s.customer_id

LEFT JOIN received_summary r
    ON c.id = r.customer_id

LEFT JOIN card_summary cs
    ON c.id = cs.customer_id

LEFT JOIN loan_summary ls
    ON c.id = ls.customer_id

LEFT JOIN loan_payment_summary lp
    ON c.id = lp.customer_id

LEFT JOIN transaction_summary ts
    ON c.id = ts.customer_id

LEFT JOIN most_used_account mua
    ON c.id = mua.customer_id

ORDER BY c.id;

-- ====================================

INSERT INTO accounts
(
    account_number,
    customer_id,
    branch_id,
    account_type,
    currency,
    balance,
    status
)
SELECT
    'STRESS001',
    1,
    1,
    'checking',
    'SAR',
    10000.00,
    'active'
WHERE NOT EXISTS
(
    SELECT 1
    FROM accounts
    WHERE account_number = 'STRESS001'
);

-- ====================================

SET @stress_account_id =
(
    SELECT id
    FROM accounts
    WHERE account_number = 'STRESS001'
);

-- ====================================

SELECT
    id,
    account_number,
    balance
FROM accounts
WHERE id = @stress_account_id;

-- ====================================

SELECT
    account_number,
    balance AS final_balance
FROM accounts
WHERE id = @stress_account_id;

-- ====================================
/*stress testi transactionstan yeniden hesapla */

WITH ordered_transactions AS
(
    SELECT
        t.*,

        ROW_NUMBER() OVER
        (
            ORDER BY t.created_at, t.id
        ) AS rn,

        CASE
            WHEN t.transaction_type IN
            ('deposit', 'transfer_in', 'refund')
                THEN t.amount

            WHEN t.transaction_type IN
            ('withdrawal', 'transfer_out', 'fee', 'loan_payment')
                THEN -t.amount

            ELSE 0
        END AS signed_amount

    FROM transactions t
    WHERE t.account_id = @stress_account_id
      AND t.status = 'completed'
),

rebuilt AS
(
    SELECT
        @stress_account_id AS account_id,

        MAX(
            CASE
                WHEN rn = 1
                THEN balance_before
            END
        )
        +
        SUM(signed_amount)
        AS calculated_balance

    FROM ordered_transactions
)

SELECT
    a.account_number,

    a.balance AS stored_balance,

    r.calculated_balance,

    a.balance - r.calculated_balance
        AS difference,

    CASE
        WHEN a.balance = r.calculated_balance
            THEN 'BALANCE OK'
        ELSE 'BALANCE MISMATCH'
    END AS integrity_status

FROM accounts a

JOIN rebuilt r
    ON a.id = r.account_id;


-- ================================================================================
 --                        DATABASE 2
-- ================================================================================


-- ============================================
-- Logistics Management System Database
-- ============================================

-- إنشاء قاعدة البيانات
CREATE DATABASE logistics_management;

USE logistics_management;


-- ============================================
-- 1. Table: customers - العملاء
-- ============================================

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    customer_type VARCHAR(20) NOT NULL,
    city VARCHAR(50),
    address VARCHAR(255),
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);


-- ============================================
-- 2. Table: branches - الفروع
-- ============================================

CREATE TABLE branches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    manager_name VARCHAR(100),
    opened_at DATE,
    status VARCHAR(20) DEFAULT 'active'
);


-- ============================================
-- 3. Table: employees - الموظفين
-- ============================================

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    job_title VARCHAR(100),
    salary DECIMAL(10,2) CHECK (salary >= 0),
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'active',

    FOREIGN KEY (branch_id)
        REFERENCES branches(id)
);


-- ============================================
-- 4. Table: drivers - السائقين
-- ============================================

CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    license_number VARCHAR(50) UNIQUE,
    license_expiry_date DATE,
    hire_date DATE,
    salary DECIMAL(10,2) CHECK (salary >= 0),
    status VARCHAR(20) DEFAULT 'active',

    FOREIGN KEY (branch_id)
        REFERENCES branches(id)
);


-- ============================================
-- 5. Table: vehicles - المركبات
-- ============================================

CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    plate_number VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50),
    model VARCHAR(100),
    manufacture_year YEAR,
    max_weight DECIMAL(10,2) NOT NULL CHECK (max_weight > 0),
    status VARCHAR(20) DEFAULT 'available',

    FOREIGN KEY (branch_id)
        REFERENCES branches(id)
);


-- ============================================
-- 6. Table: shipments - الشحنات
-- ============================================

CREATE TABLE shipments (
    id INT PRIMARY KEY AUTO_INCREMENT,

    tracking_number VARCHAR(50) UNIQUE NOT NULL,

    customer_id INT NOT NULL,
    origin_branch_id INT NOT NULL,
    destination_branch_id INT NOT NULL,

    sender_name VARCHAR(100) NOT NULL,
    sender_phone VARCHAR(20),

    receiver_name VARCHAR(100) NOT NULL,
    receiver_phone VARCHAR(20),
    receiver_address VARCHAR(255) NOT NULL,
    receiver_city VARCHAR(50) NOT NULL,

    weight DECIMAL(10,2) NOT NULL CHECK (weight > 0),
    shipping_cost DECIMAL(10,2) NOT NULL CHECK (shipping_cost >= 0),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expected_delivery_date DATE,
    delivered_at DATETIME,

    payment_status VARCHAR(20) DEFAULT 'pending',
    shipment_status VARCHAR(30) DEFAULT 'created',

    FOREIGN KEY (customer_id)
        REFERENCES customers(id),

    FOREIGN KEY (origin_branch_id)
        REFERENCES branches(id),

    FOREIGN KEY (destination_branch_id)
        REFERENCES branches(id),

    CHECK (origin_branch_id <> destination_branch_id)
);


-- ============================================
-- 7. Table: deliveries - عمليات التوصيل
-- ============================================

CREATE TABLE deliveries (
    id INT PRIMARY KEY AUTO_INCREMENT,

    shipment_id INT NOT NULL,
    driver_id INT NOT NULL,
    vehicle_id INT NOT NULL,

    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    started_at DATETIME,
    completed_at DATETIME,

    delivery_status VARCHAR(30) DEFAULT 'assigned',

    notes TEXT,

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(id),

    FOREIGN KEY (driver_id)
        REFERENCES drivers(id),

    FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(id)
);


-- ============================================
-- 8. Table: shipment_tracking - تتبع الشحنة
-- ============================================

CREATE TABLE shipment_tracking (
    id INT PRIMARY KEY AUTO_INCREMENT,

    shipment_id INT NOT NULL,
    branch_id INT NOT NULL,

    status VARCHAR(30) NOT NULL,
    description VARCHAR(255),

    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(id),

    FOREIGN KEY (branch_id)
        REFERENCES branches(id)
);


-- ============================================
-- 9. Table: payments - عمليات الدفع
-- ============================================

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,

    shipment_id INT NOT NULL,

    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),

    payment_method VARCHAR(30) NOT NULL,

    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    transaction_reference VARCHAR(100) UNIQUE,

    status VARCHAR(20) DEFAULT 'successful',

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(id)
);


-- ============================================
-- تعديلات على جدول customers
-- ============================================

-- نوع العميل
ALTER TABLE customers
ADD CONSTRAINT chk_customer_type
CHECK (
    customer_type IN (
        'individual',
        'business'
    )
);

-- حالة العميل
ALTER TABLE customers
ADD CONSTRAINT chk_customer_status
CHECK (
    status IN (
        'active',
        'inactive',
        'blocked'
    )
);


-- ============================================
-- تعديلات على جدول branches
-- ============================================

ALTER TABLE branches
ADD CONSTRAINT chk_branch_status
CHECK (
    status IN (
        'active',
        'inactive'
    )
);


-- ============================================
-- تعديلات على جدول employees
-- ============================================

ALTER TABLE employees
ADD CONSTRAINT chk_employee_status
CHECK (
    status IN (
        'active',
        'inactive'
    )
);


-- ============================================
-- تعديلات على جدول drivers
-- ============================================

ALTER TABLE drivers
ADD CONSTRAINT chk_driver_status
CHECK (
    status IN (
        'active',
        'inactive'
    )
);


-- ============================================
-- تعديلات على جدول vehicles
-- حالة المركبة
-- ============================================

ALTER TABLE vehicles
ADD CONSTRAINT chk_vehicle_status
CHECK (
    status IN (
        'available',
        'in_delivery',
        'maintenance',
        'inactive'
    )
);


-- ============================================
-- تعديلات على جدول shipments
-- ============================================

-- حالة الدفع
ALTER TABLE shipments
ADD CONSTRAINT chk_shipment_payment_status
CHECK (
    payment_status IN (
        'pending',
        'paid',
        'refunded'
    )
);


-- حالة الشحنة
ALTER TABLE shipments
ADD CONSTRAINT chk_shipment_status
CHECK (
    shipment_status IN (
        'created',
        'received',
        'in_transit',
        'out_for_delivery',
        'delivered',
        'cancelled',
        'returned'
    )
);


-- ============================================
-- تعديلات على جدول payments
-- ============================================

-- طريقة الدفع
ALTER TABLE payments
ADD CONSTRAINT chk_payment_method
CHECK (
    payment_method IN (
        'cash',
        'card',
        'pix',
        'bank_transfer'
    )
);


-- حالة الدفع
ALTER TABLE payments
ADD CONSTRAINT chk_payment_status
CHECK (
    status IN (
        'successful',
        'failed',
        'refunded'
    )
);

-- ============================================
-- ادخال بيانات 5 فروع لجدول ال branches
-- ============================================

INSERT INTO branches
(branch_name, city, address, phone, manager_name, opened_at, status)
VALUES
('Kayseri Central', 'Kayseri', 'Melikgazi, Cumhuriyet Mah.', '03522000001', 'Ahmad Hassan', '2022-03-15', 'active'),
('Istanbul Main', 'Istanbul', 'Kadikoy, Istanbul', '02162000002', 'Sara Omar', '2021-06-10', 'active'),
('Ankara Branch', 'Ankara', 'Cankaya, Ankara', '03122000003', 'Omar Khaled', '2023-01-20', 'active'),
('Izmir Branch', 'Izmir', 'Konak, Izmir', '02322000004', 'Lina Hassan', '2022-09-05', 'active'),
('Bursa Branch', 'Bursa', 'Nilufer, Bursa', '02242000005', 'Yusuf Kaya', '2024-02-12', 'active');




-- ============================================
--  customers ادخال بيانات 25 عميل لجدول العملاء 
-- ============================================
INSERT INTO customers
(full_name, email, phone, customer_type, city, address, registered_at, status)
VALUES
('Ahmad Hassan', 'ahmad.hassan@gmail.com', '0501000001', 'individual', 'Kayseri', 'Melikgazi', '2026-01-05', 'active'),
('Sara Omar', 'sara.omar@gmail.com', '0501000002', 'individual', 'Istanbul', 'Kadikoy', '2026-01-07', 'active'),
('Omar Khaled', 'omar.khaled@gmail.com', NULL, 'individual', 'Ankara', 'Cankaya', '2026-01-10', 'active'),
('Lina Hassan', 'lina.hassan@gmail.com', '0501000004', 'individual', 'Izmir', 'Konak', '2026-01-12', 'active'),
('Yusuf Kaya', 'yusuf.kaya@gmail.com', NULL, 'individual', 'Bursa', 'Nilufer', '2026-01-15', 'active'),

('Maya Smith', 'maya.smith@gmail.com', '0501000006', 'individual', 'Kayseri', 'Kocasinan', '2026-01-18', 'active'),
('Adam Brown', 'adam.brown@gmail.com', '0501000007', 'individual', 'Istanbul', 'Besiktas', '2026-01-20', 'active'),
('Nora Ali', 'nora.ali@gmail.com', NULL, 'individual', 'Ankara', 'Yenimahalle', '2026-01-22', 'active'),
('Daniel Wilson', 'daniel.wilson@gmail.com', '0501000009', 'individual', 'Izmir', 'Bornova', '2026-01-25', 'inactive'),
('Emma Davis', 'emma.davis@gmail.com', '0501000010', 'individual', 'Bursa', 'Osmangazi', '2026-01-27', 'active'),

('TechNova Ltd', 'contact@technova.com', '0502000001', 'business', 'Kayseri', 'Organize Sanayi', '2026-02-01', 'active'),
('Anatolia Foods', 'info@anatoliafoods.com', '0502000002', 'business', 'Ankara', 'Cankaya', '2026-02-03', 'active'),
('BlueLine Trading', 'info@blueline.com', NULL, 'business', 'Istanbul', 'Atasehir', '2026-02-05', 'active'),
('Green Market', 'contact@greenmarket.com', '0502000004', 'business', 'Izmir', 'Konak', '2026-02-08', 'active'),
('Bursa Textile', 'info@bursatextile.com', '0502000005', 'business', 'Bursa', 'Nilufer', '2026-02-10', 'inactive'),

('Kayseri Electronics', 'info@kayserielectronics.com', '0502000006', 'business', 'Kayseri', 'Melikgazi', '2026-02-12', 'active'),
('Istanbul Furniture', 'info@istanbulfurniture.com', '0502000007', 'business', 'Istanbul', 'Umraniye', '2026-02-15', 'active'),
('Capital Office', 'contact@capitaloffice.com', NULL, 'business', 'Ankara', 'Cankaya', '2026-02-18', 'active'),
('Aegean Textiles', 'info@aegeantextiles.com', '0502000009', 'business', 'Izmir', 'Bornova', '2026-02-20', 'blocked'),
('Marmara Logistics', 'info@marmaralogistics.com', '0502000010', 'business', 'Bursa', 'Osmangazi', '2026-02-22', 'active'),

('Huda Ahmed', 'huda.ahmed@gmail.com', '0501000021', 'individual', 'Kayseri', 'Talas', '2026-02-25', 'active'),
('Karim Saleh', 'karim.saleh@gmail.com', NULL, 'individual', 'Ankara', 'Etimesgut', '2026-02-27', 'active'),
('Fatima Noor', 'fatima.noor@gmail.com', '0501000023', 'individual', 'Istanbul', 'Uskudar', '2026-03-01', 'active'),
('James Taylor', 'james.taylor@gmail.com', '0501000024', 'individual', 'Izmir', 'Karsiyaka', '2026-03-03', 'inactive'),
('Mary Johnson', 'mary.johnson@gmail.com', '0501000025', 'individual', 'Bursa', 'Nilufer', '2026-03-05', 'active');






-- ============================================
-- ادخال بيانات 20 موظف لجدول الموظفين  employees
-- ============================================
INSERT INTO employees
(branch_id, full_name, email, phone, job_title, salary, hire_date, status)
VALUES
(1, 'Mehmet Yilmaz', 'mehmet.yilmaz@logistics.com', '0503000001', 'Branch Clerk', 28000, '2023-02-10', 'active'),
(1, 'Ayse Demir', 'ayse.demir@logistics.com', '0503000002', 'Customer Service', 30000, '2023-05-15', 'active'),
(1, 'Hasan Kaya', 'hasan.kaya@logistics.com', '0503000003', 'Operations Officer', 35000, '2024-01-20', 'active'),
(1, 'Zeynep Acar', 'zeynep.acar@logistics.com', '0503000004', 'Accountant', 38000, '2022-09-12', 'active'),

(2, 'Ali Demir', 'ali.demir@logistics.com', '0503000005', 'Branch Clerk', 29000, '2023-03-18', 'active'),
(2, 'Elif Kaya', 'elif.kaya@logistics.com', '0503000006', 'Customer Service', 31000, '2023-07-22', 'active'),
(2, 'Murat Ozkan', 'murat.ozkan@logistics.com', '0503000007', 'Operations Officer', 36000, '2024-02-14', 'active'),
(2, 'Selin Arslan', 'selin.arslan@logistics.com', '0503000008', 'Branch Manager', 48000, '2021-11-05', 'active'),

(3, 'Emre Yildiz', 'emre.yildiz@logistics.com', '0503000009', 'Branch Clerk', 27500, '2024-03-10', 'active'),
(3, 'Derya Sahin', 'derya.sahin@logistics.com', '0503000010', 'Customer Service', 30500, '2023-08-17', 'active'),
(3, 'Burak Celik', 'burak.celik@logistics.com', '0503000011', 'Operations Officer', 37000, '2022-12-01', 'active'),
(3, 'Nesrin Kurt', 'nesrin.kurt@logistics.com', '0503000012', 'Accountant', 39000, '2023-06-25', 'inactive'),

(4, 'Can Erdem', 'can.erdem@logistics.com', '0503000013', 'Branch Clerk', 28500, '2024-01-05', 'active'),
(4, 'Ece Gunes', 'ece.gunes@logistics.com', '0503000014', 'Customer Service', 32000, '2023-04-11', 'active'),
(4, 'Kerem Aslan', 'kerem.aslan@logistics.com', '0503000015', 'Operations Officer', 35500, '2022-10-19', 'active'),
(4, 'Sibel Tas', 'sibel.tas@logistics.com', '0503000016', 'Branch Manager', 47000, '2022-02-08', 'active'),

(5, 'Okan Polat', 'okan.polat@logistics.com', '0503000017', 'Branch Clerk', 28000, '2024-05-12', 'active'),
(5, 'Buse Cakir', 'buse.cakir@logistics.com', '0503000018', 'Customer Service', 31500, '2023-09-20', 'active'),
(5, 'Tolga Koc', 'tolga.koc@logistics.com', '0503000019', 'Operations Officer', 36500, '2022-07-14', 'active'),
(5, 'Esra Yalcin', 'esra.yalcin@logistics.com', '0503000020', 'Accountant', 40000, '2023-01-30', 'active');


-- ============================================
-- ادخال بيانات 12 سائق لجول السائقين drivers
-- ============================================
INSERT INTO drivers
(branch_id, full_name, phone, license_number, license_expiry_date, hire_date, salary, status)
VALUES
(1, 'Ahmad Yasin', '0504000001', 'LIC-KS-1001', '2028-05-20', '2023-03-10', 38000, 'active'),
(1, 'Mustafa Ali', '0504000002', 'LIC-KS-1002', '2027-11-15', '2024-01-12', 36000, 'active'),
(1, 'Hakan Demir', '0504000003', 'LIC-KS-1003', '2029-02-18', '2022-08-05', 40000, 'active'),

(2, 'Mehmet Arslan', '0504000004', 'LIC-IST-1004', '2028-09-10', '2023-05-22', 39000, 'active'),
(2, 'Serkan Kaya', '0504000005', 'LIC-IST-1005', '2027-12-30', '2024-02-15', 37000, 'active'),
(2, 'Cem Ozkan', '0504000006', 'LIC-IST-1006', '2029-06-12', '2022-11-20', 42000, 'active'),

(3, 'Burak Yilmaz', '0504000007', 'LIC-ANK-1007', '2028-03-25', '2023-07-18', 38500, 'active'),
(3, 'Eren Sahin', '0504000008', 'LIC-ANK-1008', '2027-10-05', '2024-03-01', 35500, 'active'),

(4, 'Kaan Celik', '0504000009', 'LIC-IZM-1009', '2029-01-15', '2022-09-10', 41000, 'active'),
(4, 'Mert Acar', '0504000010', 'LIC-IZM-1010', '2028-07-22', '2023-12-05', 37500, 'active'),

(5, 'Ozan Kaya', '0504000011', 'LIC-BRS-1011', '2027-09-18', '2024-01-25', 36500, 'active'),
(5, 'Emir Tas', '0504000012', 'LIC-BRS-1012', '2029-04-30', '2023-06-14', 39500, 'active');




-- ============================================
-- ادخال بيانات 10 مركبات لجدول المركبات vehicles--
-- ============================================
INSERT INTO vehicles
(branch_id, plate_number, vehicle_type, model, manufacture_year, max_weight, status)
VALUES
(1, '38 ABC 101', 'Van', 'Ford Transit', 2022, 1500, 'available'),
(1, '38 ABC 102', 'Truck', 'Mercedes Atego', 2021, 5000, 'available'),

(2, '34 XYZ 201', 'Van', 'Fiat Ducato', 2023, 1800, 'available'),
(2, '34 XYZ 202', 'Truck', 'Isuzu NPR', 2020, 4500, 'maintenance'),

(3, '06 DEF 301', 'Van', 'Ford Transit', 2022, 1500, 'available'),
(3, '06 DEF 302', 'Truck', 'Mercedes Atego', 2023, 6000, 'available'),

(4, '35 GHI 401', 'Van', 'Renault Master', 2021, 1700, 'available'),
(4, '35 GHI 402', 'Truck', 'Isuzu NPR', 2022, 4000, 'available'),

(5, '16 JKL 501', 'Van', 'Fiat Ducato', 2023, 1800, 'available'),
(5, '16 JKL 502', 'Truck', 'Ford Cargo', 2020, 5500, 'inactive');





-- ============================================
-- ادخال 10 بيانات لجدول الشحنات shipments
-- ============================================
INSERT INTO shipments
(
    tracking_number,
    customer_id,
    origin_branch_id,
    destination_branch_id,
    sender_name,
    sender_phone,
    receiver_name,
    receiver_phone,
    receiver_address,
    receiver_city,
    weight,
    shipping_cost,
    created_at,
    expected_delivery_date,
    delivered_at,
    payment_status,
    shipment_status
)
VALUES
('TRK100001', 1, 1, 2, 'Ahmad Hassan', '0501000001', 'Sara Omar', '0505000001', 'Kadikoy', 'Istanbul', 2.5, 180, '2026-01-05 09:00:00', '2026-01-08', NULL, 'paid', 'in_transit'),

('TRK100002', 2, 2, 3, 'Sara Omar', '0501000002', 'Omar Khaled', '0505000002', 'Cankaya', 'Ankara', 5.0, 300, '2026-01-06 10:00:00', '2026-01-10', NULL, 'pending', 'received'),

('TRK100003', 3, 3, 1, 'Omar Khaled', '0501000003', 'Ahmad Hassan', '0505000003', 'Melikgazi', 'Kayseri', 1.5, 120, '2026-01-07 11:00:00', '2026-01-09', NULL, 'paid', 'out_for_delivery'),

('TRK100004', 4, 1, 4, 'Lina Hassan', '0501000004', 'Maya Smith', '0505000004', 'Konak', 'Izmir', 8.0, 450, '2026-01-08 09:30:00', '2026-01-12', NULL, 'paid', 'in_transit'),

('TRK100005', 5, 4, 5, 'Yusuf Kaya', '0501000005', 'Adam Brown', '0505000005', 'Nilufer', 'Bursa', 3.2, 220, '2026-01-09 12:00:00', '2026-01-13', NULL, 'pending', 'created'),

('TRK100006', 6, 5, 1, 'Maya Smith', '0501000006', 'Nora Ali', '0505000006', 'Talas', 'Kayseri', 12.0, 600, '2026-01-10 08:30:00', '2026-01-14', NULL, 'paid', 'received'),

('TRK100007', 7, 2, 4, 'Adam Brown', '0501000007', 'Daniel Wilson', '0505000007', 'Bornova', 'Izmir', 4.5, 275, '2026-01-11 14:00:00', '2026-01-15', NULL, 'paid', 'in_transit'),

('TRK100008', 8, 3, 5, 'Nora Ali', '0501000008', 'Emma Davis', '0505000008', 'Osmangazi', 'Bursa', 2.0, 150, '2026-01-12 09:00:00', '2026-01-16', NULL, 'pending', 'created'),

('TRK100009', 9, 4, 2, 'Daniel Wilson', '0501000009', 'TechNova Ltd', '0505000009', 'Atasehir', 'Istanbul', 15.0, 750, '2026-01-13 10:30:00', '2026-01-18', NULL, 'paid', 'in_transit'),

('TRK100010', 10, 5, 3, 'Emma Davis', '0501000010', 'Anatolia Foods', '0505000010', 'Cankaya', 'Ankara', 20.0, 900, '2026-01-14 13:00:00', NULL, NULL, 'pending', 'cancelled');



-- ============================================
-- ادخال 50 بيانات لجدول الشحنات shipments
-- ============================================

INSERT INTO shipments
(
    tracking_number,
    customer_id,
    origin_branch_id,
    destination_branch_id,
    sender_name,
    sender_phone,
    receiver_name,
    receiver_phone,
    receiver_address,
    receiver_city,
    weight,
    shipping_cost,
    created_at,
    expected_delivery_date,
    delivered_at,
    payment_status,
    shipment_status
)
VALUES
('TRK100011', 11, 1, 2, 'TechNova Ltd', '0502000001', 'BlueLine Trading', '0506000001', 'Atasehir', 'Istanbul', 6.0, 350, '2026-01-15 09:00:00', '2026-01-19', NULL, 'paid', 'delivered'),

('TRK100012', 12, 2, 3, 'Anatolia Foods', '0502000002', 'Capital Office', '0506000002', 'Cankaya', 'Ankara', 10.0, 500, '2026-01-16 10:00:00', '2026-01-20', NULL, 'paid', 'delivered'),

('TRK100013', 13, 3, 4, 'BlueLine Trading', '0502000003', 'Green Market', '0506000003', 'Konak', 'Izmir', 7.5, 420, '2026-01-17 11:00:00', '2026-01-21', NULL, 'pending', 'in_transit'),

('TRK100014', 14, 4, 5, 'Green Market', '0502000004', 'Bursa Textile', '0506000004', 'Nilufer', 'Bursa', 9.0, 480, '2026-01-18 09:30:00', '2026-01-22', NULL, 'paid', 'delivered'),

('TRK100015', 15, 5, 1, 'Bursa Textile', '0502000005', 'Kayseri Electronics', '0506000005', 'Melikgazi', 'Kayseri', 14.0, 700, '2026-01-19 12:00:00', '2026-01-24', NULL, 'pending', 'returned'),

('TRK100016', 16, 1, 3, 'Kayseri Electronics', '0502000006', 'Marmara Logistics', '0506000006', 'Osmangazi', 'Bursa', 11.0, 580, '2026-01-20 08:30:00', '2026-01-25', NULL, 'paid', 'delivered'),

('TRK100017', 17, 2, 4, 'Istanbul Furniture', '0502000007', 'Aegean Textiles', '0506000007', 'Bornova', 'Izmir', 18.0, 850, '2026-01-21 14:00:00', '2026-01-26', NULL, 'paid', 'in_transit'),

('TRK100018', 18, 3, 5, 'Capital Office', '0502000008', 'Marmara Logistics', '0506000008', 'Nilufer', 'Bursa', 4.0, 240, '2026-01-22 09:00:00', '2026-01-27', NULL, 'pending', 'created'),

('TRK100019', 19, 4, 2, 'Aegean Textiles', '0502000009', 'Istanbul Furniture', '0506000009', 'Umraniye', 'Istanbul', 16.0, 800, '2026-01-23 10:30:00', '2026-01-28', NULL, 'paid', 'delivered'),

('TRK100020', 20, 5, 3, 'Marmara Logistics', '0502000010', 'Anatolia Foods', '0506000010', 'Cankaya', 'Ankara', 22.0, 950, '2026-01-24 13:00:00', '2026-01-29', NULL, 'pending', 'cancelled'),

('TRK100021', 21, 1, 4, 'Huda Ahmed', '0501000021', 'Green Market', '0506000021', 'Konak', 'Izmir', 3.5, 210, '2026-01-25 09:00:00', '2026-01-29', NULL, 'paid', 'delivered'),

('TRK100022', 22, 2, 5, 'Karim Saleh', '0501000022', 'Bursa Textile', '0506000022', 'Nilufer', 'Bursa', 5.5, 300, '2026-01-26 10:00:00', '2026-01-30', NULL, 'pending', 'in_transit'),

('TRK100023', 23, 3, 1, 'Fatima Noor', '0501000023', 'Ahmad Hassan', '0506000023', 'Talas', 'Kayseri', 2.5, 170, '2026-01-27 11:00:00', '2026-01-31', NULL, 'paid', 'delivered'),

('TRK100024', 24, 4, 2, 'James Taylor', '0501000024', 'Sara Omar', '0506000024', 'Kadikoy', 'Istanbul', 8.5, 460, '2026-01-28 12:00:00', '2026-02-02', NULL, 'paid', 'delivered'),

('TRK100025', 25, 5, 1, 'Mary Johnson', '0501000025', 'Ahmad Hassan', '0506000025', 'Melikgazi', 'Kayseri', 6.5, 330, '2026-01-29 13:00:00', '2026-02-03', NULL, 'pending', 'in_transit'),

('TRK100026', 1, 1, 3, 'Ahmad Hassan', '0501000001', 'Omar Khaled', '0506000026', 'Cankaya', 'Ankara', 4.5, 260, '2026-02-01 09:00:00', '2026-02-06', NULL, 'paid', 'delivered'),

('TRK100027', 2, 2, 4, 'Sara Omar', '0501000002', 'Maya Smith', '0506000027', 'Konak', 'Izmir', 9.5, 520, '2026-02-02 10:00:00', '2026-02-07', NULL, 'paid', 'delivered'),

('TRK100028', 3, 3, 5, 'Omar Khaled', '0501000003', 'Adam Brown', '0506000028', 'Nilufer', 'Bursa', 13.0, 650, '2026-02-03 11:00:00', '2026-02-08', NULL, 'pending', 'received'),

('TRK100029', 4, 4, 1, 'Lina Hassan', '0501000004', 'Nora Ali', '0506000029', 'Talas', 'Kayseri', 3.0, 190, '2026-02-04 09:30:00', '2026-02-09', NULL, 'paid', 'delivered'),

('TRK100030', 5, 5, 2, 'Yusuf Kaya', '0501000005', 'Daniel Wilson', '0506000030', 'Besiktas', 'Istanbul', 7.0, 390, '2026-02-05 12:00:00', '2026-02-10', NULL, 'pending', 'cancelled'),

('TRK100031', 6, 1, 5, 'Maya Smith', '0501000006', 'Emma Davis', '0506000031', 'Osmangazi', 'Bursa', 5.0, 280, '2026-02-06 08:30:00', '2026-02-11', NULL, 'paid', 'delivered'),

('TRK100032', 7, 2, 1, 'Adam Brown', '0501000007', 'Huda Ahmed', '0506000032', 'Talas', 'Kayseri', 2.0, 140, '2026-02-07 14:00:00', '2026-02-12', NULL, 'paid', 'delivered'),

('TRK100033', 8, 3, 2, 'Nora Ali', '0501000008', 'Karim Saleh', '0506000033', 'Cankaya', 'Ankara', 12.5, 620, '2026-02-08 09:00:00', '2026-02-13', NULL, 'pending', 'in_transit'),

('TRK100034', 9, 4, 3, 'Daniel Wilson', '0501000009', 'Fatima Noor', '0506000034', 'Cankaya', 'Ankara', 4.0, 230, '2026-02-09 10:30:00', '2026-02-14', NULL, 'paid', 'delivered'),

('TRK100035', 10, 5, 4, 'Emma Davis', '0501000010', 'James Taylor', '0506000035', 'Bornova', 'Izmir', 10.5, 550, '2026-02-10 13:00:00', '2026-02-15', NULL, 'paid', 'delivered'),

('TRK100036', 11, 1, 2, 'TechNova Ltd', '0502000001', 'Istanbul Furniture', '0506000036', 'Umraniye', 'Istanbul', 17.0, 820, '2026-02-11 09:00:00', '2026-02-16', NULL, 'pending', 'received'),

('TRK100037', 12, 2, 3, 'Anatolia Foods', '0502000002', 'Capital Office', '0506000037', 'Cankaya', 'Ankara', 6.0, 340, '2026-02-12 10:00:00', '2026-02-17', NULL, 'paid', 'delivered'),

('TRK100038', 13, 3, 4, 'BlueLine Trading', '0502000003', 'Green Market', '0506000038', 'Konak', 'Izmir', 8.0, 430, '2026-02-13 11:00:00', '2026-02-18', NULL, 'paid', 'delivered'),

('TRK100039', 14, 4, 5, 'Green Market', '0502000004', 'Bursa Textile', '0506000039', 'Nilufer', 'Bursa', 5.0, 290, '2026-02-14 09:30:00', '2026-02-19', NULL, 'pending', 'in_transit'),

('TRK100040', 15, 5, 1, 'Bursa Textile', '0502000005', 'Kayseri Electronics', '0506000040', 'Melikgazi', 'Kayseri', 19.0, 900, '2026-02-15 12:00:00', '2026-02-20', NULL, 'paid', 'delivered'),

('TRK100041', 16, 1, 3, 'Kayseri Electronics', '0502000006', 'Anatolia Foods', '0506000041', 'Cankaya', 'Ankara', 11.5, 570, '2026-02-16 08:30:00', '2026-02-21', NULL, 'pending', 'returned'),

('TRK100042', 17, 2, 5, 'Istanbul Furniture', '0502000007', 'Marmara Logistics', '0506000042', 'Nilufer', 'Bursa', 15.0, 730, '2026-02-17 14:00:00', '2026-02-22', NULL, 'paid', 'delivered'),

('TRK100043', 18, 3, 1, 'Capital Office', '0502000008', 'Ahmad Hassan', '0506000043', 'Melikgazi', 'Kayseri', 3.5, 200, '2026-02-18 09:00:00', '2026-02-23', NULL, 'paid', 'delivered'),

('TRK100044', 19, 4, 2, 'Aegean Textiles', '0502000009', 'Sara Omar', '0506000044', 'Kadikoy', 'Istanbul', 7.5, 410, '2026-02-19 10:30:00', '2026-02-24', NULL, 'pending', 'in_transit'),

('TRK100045', 20, 5, 3, 'Marmara Logistics', '0502000010', 'Omar Khaled', '0506000045', 'Cankaya', 'Ankara', 21.0, 980, '2026-02-20 13:00:00', '2026-02-25', NULL, 'paid', 'delivered'),

('TRK100046', 21, 1, 4, 'Huda Ahmed', '0501000021', 'Lina Hassan', '0506000046', 'Konak', 'Izmir', 2.5, 160, '2026-02-21 09:00:00', '2026-02-26', NULL, 'paid', 'delivered'),

('TRK100047', 22, 2, 5, 'Karim Saleh', '0501000022', 'Yusuf Kaya', '0506000047', 'Nilufer', 'Bursa', 6.5, 350, '2026-02-22 10:00:00', '2026-02-27', NULL, 'pending', 'created'),

('TRK100048', 23, 3, 2, 'Fatima Noor', '0501000023', 'Maya Smith', '0506000048', 'Kadikoy', 'Istanbul', 4.5, 270, '2026-02-23 11:00:00', '2026-02-28', NULL, 'paid', 'delivered'),

('TRK100049', 24, 4, 1, 'James Taylor', '0501000024', 'Nora Ali', '0506000049', 'Talas', 'Kayseri', 9.0, 480, '2026-02-24 12:00:00', '2026-03-01', NULL, 'paid', 'delivered'),

('TRK100050', 25, 5, 2, 'Mary Johnson', '0501000025', 'Adam Brown', '0506000050', 'Besiktas', 'Istanbul', 13.5, 670, '2026-02-25 13:00:00', '2026-03-02', NULL, 'pending', 'in_transit'),

('TRK100051', 1, 1, 5, 'Ahmad Hassan', '0501000001', 'Marmara Logistics', '0506000051', 'Osmangazi', 'Bursa', 18.0, 850, '2026-02-26 09:00:00', '2026-03-03', NULL, 'paid', 'delivered'),

('TRK100052', 2, 2, 3, 'Sara Omar', '0501000002', 'Anatolia Foods', '0506000052', 'Cankaya', 'Ankara', 5.0, 300, '2026-02-27 10:00:00', '2026-03-04', NULL, 'pending', 'in_transit'),

('TRK100053', 3, 3, 4, 'Omar Khaled', '0501000003', 'Green Market', '0506000053', 'Konak', 'Izmir', 7.0, 380, '2026-02-28 11:00:00', '2026-03-05', NULL, 'paid', 'delivered'),

('TRK100054', 4, 4, 5, 'Lina Hassan', '0501000004', 'Bursa Textile', '0506000054', 'Nilufer', 'Bursa', 10.0, 520, '2026-03-01 09:30:00', '2026-03-06', NULL, 'paid', 'delivered'),

('TRK100055', 5, 5, 1, 'Yusuf Kaya', '0501000005', 'Kayseri Electronics', '0506000055', 'Melikgazi', 'Kayseri', 14.5, 710, '2026-03-02 12:00:00', '2026-03-07', NULL, 'pending', 'cancelled'),

('TRK100056', 6, 1, 3, 'Maya Smith', '0501000006', 'Capital Office', '0506000056', 'Cankaya', 'Ankara', 8.5, 450, '2026-03-03 08:30:00', '2026-03-08', NULL, 'paid', 'delivered'),

('TRK100057', 7, 2, 4, 'Adam Brown', '0501000007', 'Aegean Textiles', '0506000057', 'Bornova', 'Izmir', 12.0, 620, '2026-03-04 14:00:00', '2026-03-09', NULL, 'pending', 'received'),

('TRK100058', 8, 3, 5, 'Nora Ali', '0501000008', 'Marmara Logistics', '0506000058', 'Nilufer', 'Bursa', 3.0, 190, '2026-03-05 09:00:00', '2026-03-10', NULL, 'paid', 'delivered'),

('TRK100059', 9, 4, 2, 'Daniel Wilson', '0501000009', 'Istanbul Furniture', '0506000059', 'Umraniye', 'Istanbul', 16.5, 780, '2026-03-06 10:30:00', '2026-03-11', NULL, 'pending', 'in_transit'),

('TRK100060', 10, 5, 4, 'Emma Davis', '0501000010', 'Green Market', '0506000060', 'Konak', 'Izmir', 20.0, 920, '2026-03-07 13:00:00', '2026-03-12', NULL, 'paid', 'delivered');

-- ============================================
-- ادخال بيانات 40 عملية توصيل لجدول ال deliveries
-- ============================================
INSERT INTO deliveries
(
    shipment_id,
    driver_id,
    vehicle_id,
    assigned_at,
    started_at,
    completed_at,
    delivery_status,
    notes
)
VALUES
(11, 1, 1, '2026-01-15 10:00:00', '2026-01-15 11:00:00', '2026-01-16 15:00:00', 'completed', 'Delivered successfully'),
(12, 2, 2, '2026-01-16 11:00:00', '2026-01-16 12:00:00', '2026-01-17 16:00:00', 'completed', 'Delivered successfully'),
(14, 4, 3, '2026-01-18 10:00:00', '2026-01-18 11:00:00', '2026-01-19 14:00:00', 'completed', 'Delivered successfully'),
(16, 6, 5, '2026-01-20 09:00:00', '2026-01-20 10:00:00', '2026-01-21 13:00:00', 'completed', 'Delivered successfully'),
(19, 9, 7, '2026-01-23 11:00:00', '2026-01-23 12:00:00', '2026-01-24 17:00:00', 'completed', 'Delivered successfully'),
(21, 1, 1, '2026-01-25 10:00:00', '2026-01-25 11:00:00', '2026-01-26 15:00:00', 'completed', 'Delivered successfully'),
(23, 7, 5, '2026-01-27 12:00:00', '2026-01-27 13:00:00', '2026-01-28 16:00:00', 'completed', 'Delivered successfully'),
(24, 4, 3, '2026-01-28 13:00:00', '2026-01-28 14:00:00', '2026-01-29 15:00:00', 'completed', 'Delivered successfully'),

(26, 2, 2, '2026-02-01 10:00:00', '2026-02-01 11:00:00', '2026-02-02 16:00:00', 'completed', 'Delivered successfully'),
(27, 6, 6, '2026-02-02 11:00:00', '2026-02-02 12:00:00', '2026-02-03 15:00:00', 'completed', 'Delivered successfully'),
(29, 9, 7, '2026-02-04 10:00:00', '2026-02-04 11:00:00', '2026-02-05 14:00:00', 'completed', 'Delivered successfully'),
(31, 1, 1, '2026-02-06 09:00:00', '2026-02-06 10:00:00', '2026-02-07 15:00:00', 'completed', 'Delivered successfully'),
(32, 2, 2, '2026-02-07 15:00:00', '2026-02-07 16:00:00', '2026-02-08 14:00:00', 'completed', 'Delivered successfully'),
(34, 4, 3, '2026-02-09 11:00:00', '2026-02-09 12:00:00', '2026-02-10 16:00:00', 'completed', 'Delivered successfully'),
(35, 6, 6, '2026-02-10 14:00:00', '2026-02-10 15:00:00', '2026-02-11 17:00:00', 'completed', 'Delivered successfully'),
(37, 9, 7, '2026-02-12 11:00:00', '2026-02-12 12:00:00', '2026-02-13 16:00:00', 'completed', 'Delivered successfully'),

(38, 1, 1, '2026-02-13 12:00:00', '2026-02-13 13:00:00', '2026-02-14 15:00:00', 'completed', 'Delivered successfully'),
(40, 4, 3, '2026-02-15 13:00:00', '2026-02-15 14:00:00', '2026-02-16 17:00:00', 'completed', 'Delivered successfully'),
(42, 6, 5, '2026-02-17 11:00:00', '2026-02-17 12:00:00', '2026-02-18 16:00:00', 'completed', 'Delivered successfully'),
(43, 9, 7, '2026-02-18 10:00:00', '2026-02-18 11:00:00', '2026-02-19 15:00:00', 'completed', 'Delivered successfully'),
(45, 2, 2, '2026-02-20 14:00:00', '2026-02-20 15:00:00', '2026-02-21 16:00:00', 'completed', 'Delivered successfully'),
(46, 4, 3, '2026-02-21 10:00:00', '2026-02-21 11:00:00', '2026-02-22 15:00:00', 'completed', 'Delivered successfully'),
(48, 6, 5, '2026-02-23 12:00:00', '2026-02-23 13:00:00', '2026-02-24 16:00:00', 'completed', 'Delivered successfully'),
(49, 9, 7, '2026-02-24 13:00:00', '2026-02-24 14:00:00', '2026-02-25 17:00:00', 'completed', 'Delivered successfully'),

(51, 1, 1, '2026-02-26 10:00:00', '2026-02-26 11:00:00', '2026-02-27 15:00:00', 'completed', 'Delivered successfully'),
(53, 2, 2, '2026-02-28 12:00:00', '2026-02-28 13:00:00', '2026-03-01 16:00:00', 'completed', 'Delivered successfully'),
(54, 4, 3, '2026-03-01 10:00:00', '2026-03-01 11:00:00', '2026-03-02 15:00:00', 'completed', 'Delivered successfully'),
(56, 6, 5, '2026-03-03 10:00:00', '2026-03-03 11:00:00', '2026-03-04 16:00:00', 'completed', 'Delivered successfully'),
(58, 9, 7, '2026-03-05 10:00:00', '2026-03-05 11:00:00', '2026-03-06 15:00:00', 'completed', 'Delivered successfully'),
(60, 1, 1, '2026-03-07 14:00:00', '2026-03-07 15:00:00', '2026-03-08 16:00:00', 'completed', 'Delivered successfully'),

(13, 3, 4, '2026-01-17 12:00:00', '2026-01-17 13:00:00', NULL, 'in_progress', 'Delivery in progress'),
(17, 5, 6, '2026-01-21 15:00:00', '2026-01-21 16:00:00', NULL, 'in_progress', 'Currently in transit'),
(22, 8, 8, '2026-01-26 11:00:00', NULL, NULL, 'assigned', 'Waiting to start'),
(28, 3, 4, '2026-02-03 13:00:00', '2026-02-03 14:00:00', NULL, 'in_progress', 'Delivery in progress'),
(33, 7, 5, '2026-02-08 12:00:00', NULL, NULL, 'assigned', 'Waiting for driver'),
(36, 10, 9, '2026-02-11 11:00:00', '2026-02-11 12:00:00', NULL, 'in_progress', 'Delivery in progress'),
(39, 5, 6, '2026-02-14 12:00:00', NULL, NULL, 'cancelled', 'Customer cancelled delivery'),
(44, 8, 8, '2026-02-19 12:00:00', NULL, NULL, 'failed', 'Receiver unavailable'),
(47, 10, 9, '2026-02-22 13:00:00', '2026-02-22 14:00:00', NULL, 'in_progress', 'Delivery in progress'),
(50, 3, 4, '2026-02-25 11:00:00', NULL, NULL, 'assigned', 'Waiting to start');


-- ============================================
-- shipment_tracking ادخال بيانات 20 سجل تتبع الشحنات لجدول 
-- ============================================
INSERT INTO shipment_tracking
(shipment_id, branch_id, status, description, recorded_at)
VALUES
(1, 1, 'created', 'Shipment created at origin branch', '2026-01-05 09:05:00'),
(1, 1, 'in_transit', 'Shipment left origin branch', '2026-01-05 14:00:00'),

(2, 2, 'created', 'Shipment created at origin branch', '2026-01-06 10:05:00'),
(2, 2, 'received', 'Shipment received at origin branch', '2026-01-06 13:00:00'),

(3, 3, 'created', 'Shipment created at origin branch', '2026-01-07 11:05:00'),
(3, 1, 'out_for_delivery', 'Shipment is out for delivery', '2026-01-08 09:00:00'),

(4, 1, 'created', 'Shipment created at origin branch', '2026-01-08 09:35:00'),
(4, 1, 'in_transit', 'Shipment left origin branch', '2026-01-08 15:00:00'),

(5, 4, 'created', 'Shipment created at origin branch', '2026-01-09 12:05:00'),
(5, 4, 'created', 'Shipment is waiting for processing', '2026-01-09 15:00:00'),

(6, 5, 'created', 'Shipment created at origin branch', '2026-01-10 08:35:00'),
(6, 5, 'received', 'Shipment received and registered', '2026-01-10 12:00:00'),

(7, 2, 'created', 'Shipment created at origin branch', '2026-01-11 14:05:00'),
(7, 2, 'in_transit', 'Shipment departed from branch', '2026-01-12 08:00:00'),

(8, 3, 'created', 'Shipment created at origin branch', '2026-01-12 09:05:00'),
(8, 3, 'created', 'Shipment waiting for processing', '2026-01-12 13:00:00'),

(9, 4, 'created', 'Shipment created at origin branch', '2026-01-13 10:35:00'),
(9, 4, 'in_transit', 'Shipment departed from origin branch', '2026-01-13 16:00:00'),

(10, 5, 'created', 'Shipment created at origin branch', '2026-01-14 13:05:00'),
(10, 5, 'cancelled', 'Shipment cancelled by customer', '2026-01-15 10:00:00');

-- ============================================
-- shipment_tracking ادخال بيانات 100 سجل تتبع الشحنات لجدول 
-- ============================================

INSERT INTO shipment_tracking
(shipment_id, branch_id, status, description, recorded_at)
VALUES
(11,1,'created','Shipment created','2026-01-15 09:05:00'),
(11,2,'delivered','Shipment delivered successfully','2026-01-16 15:00:00'),

(12,2,'created','Shipment created','2026-01-16 10:05:00'),
(12,3,'delivered','Shipment delivered successfully','2026-01-17 16:00:00'),

(13,3,'created','Shipment created','2026-01-17 11:05:00'),
(13,4,'in_transit','Shipment in transit','2026-01-18 09:00:00'),

(14,4,'created','Shipment created','2026-01-18 09:35:00'),
(14,5,'delivered','Shipment delivered successfully','2026-01-19 14:00:00'),

(15,5,'created','Shipment created','2026-01-19 12:05:00'),
(15,5,'returned','Shipment returned to sender','2026-01-21 15:00:00'),

(16,1,'created','Shipment created','2026-01-20 08:35:00'),
(16,3,'delivered','Shipment delivered successfully','2026-01-21 13:00:00'),

(17,2,'created','Shipment created','2026-01-21 14:05:00'),
(17,4,'in_transit','Shipment in transit','2026-01-22 10:00:00'),

(18,3,'created','Shipment created','2026-01-22 09:05:00'),
(18,3,'created','Shipment waiting for processing','2026-01-23 11:00:00'),

(19,4,'created','Shipment created','2026-01-23 10:35:00'),
(19,2,'delivered','Shipment delivered successfully','2026-01-24 17:00:00'),

(20,5,'created','Shipment created','2026-01-24 13:05:00'),
(20,5,'cancelled','Shipment cancelled','2026-01-25 10:00:00'),

(21,1,'created','Shipment created','2026-01-25 09:05:00'),
(21,4,'delivered','Shipment delivered successfully','2026-01-26 15:00:00'),

(22,2,'created','Shipment created','2026-01-26 10:05:00'),
(22,5,'in_transit','Shipment in transit','2026-01-27 09:00:00'),

(23,3,'created','Shipment created','2026-01-27 11:05:00'),
(23,1,'delivered','Shipment delivered successfully','2026-01-28 16:00:00'),

(24,4,'created','Shipment created','2026-01-28 12:05:00'),
(24,2,'delivered','Shipment delivered successfully','2026-01-29 15:00:00'),

(25,5,'created','Shipment created','2026-01-29 13:05:00'),
(25,1,'in_transit','Shipment in transit','2026-01-30 10:00:00'),

(26,1,'created','Shipment created','2026-02-01 09:05:00'),
(26,3,'delivered','Shipment delivered successfully','2026-02-02 16:00:00'),

(27,2,'created','Shipment created','2026-02-02 10:05:00'),
(27,4,'delivered','Shipment delivered successfully','2026-02-03 15:00:00'),

(28,3,'created','Shipment created','2026-02-03 11:05:00'),
(28,5,'received','Shipment received at destination branch','2026-02-04 10:00:00'),

(29,4,'created','Shipment created','2026-02-04 09:35:00'),
(29,1,'delivered','Shipment delivered successfully','2026-02-05 14:00:00'),

(30,5,'created','Shipment created','2026-02-05 12:05:00'),
(30,5,'cancelled','Shipment cancelled','2026-02-06 09:00:00'),

(31,1,'created','Shipment created','2026-02-06 08:35:00'),
(31,5,'delivered','Shipment delivered successfully','2026-02-07 15:00:00'),

(32,2,'created','Shipment created','2026-02-07 14:05:00'),
(32,1,'delivered','Shipment delivered successfully','2026-02-08 14:00:00'),

(33,3,'created','Shipment created','2026-02-08 09:05:00'),
(33,2,'in_transit','Shipment in transit','2026-02-09 11:00:00'),

(34,4,'created','Shipment created','2026-02-09 10:35:00'),
(34,3,'delivered','Shipment delivered successfully','2026-02-10 16:00:00'),

(35,5,'created','Shipment created','2026-02-10 13:05:00'),
(35,4,'delivered','Shipment delivered successfully','2026-02-11 17:00:00'),

(36,1,'created','Shipment created','2026-02-11 09:05:00'),
(36,3,'received','Shipment received at destination branch','2026-02-12 10:00:00'),

(37,2,'created','Shipment created','2026-02-12 10:05:00'),
(37,3,'delivered','Shipment delivered successfully','2026-02-13 16:00:00'),

(38,3,'created','Shipment created','2026-02-13 11:05:00'),
(38,4,'delivered','Shipment delivered successfully','2026-02-14 15:00:00'),

(39,4,'created','Shipment created','2026-02-14 09:35:00'),
(39,5,'in_transit','Shipment in transit','2026-02-15 10:00:00'),

(40,5,'created','Shipment created','2026-02-15 12:05:00'),
(40,1,'delivered','Shipment delivered successfully','2026-02-16 17:00:00'),

(41,1,'created','Shipment created','2026-02-16 08:35:00'),
(41,3,'returned','Shipment returned to sender','2026-02-18 16:00:00'),

(42,2,'created','Shipment created','2026-02-17 14:05:00'),
(42,5,'delivered','Shipment delivered successfully','2026-02-18 16:00:00'),

(43,3,'created','Shipment created','2026-02-18 09:05:00'),
(43,1,'delivered','Shipment delivered successfully','2026-02-19 15:00:00'),

(44,4,'created','Shipment created','2026-02-19 10:35:00'),
(44,2,'in_transit','Shipment in transit','2026-02-20 11:00:00'),

(45,5,'created','Shipment created','2026-02-20 13:05:00'),
(45,3,'delivered','Shipment delivered successfully','2026-02-21 16:00:00'),

(46,1,'created','Shipment created','2026-02-21 09:05:00'),
(46,4,'delivered','Shipment delivered successfully','2026-02-22 15:00:00'),

(47,2,'created','Shipment created','2026-02-22 10:05:00'),
(47,5,'created','Shipment waiting for processing','2026-02-23 11:00:00'),

(48,3,'created','Shipment created','2026-02-23 11:05:00'),
(48,2,'delivered','Shipment delivered successfully','2026-02-24 16:00:00'),

(49,4,'created','Shipment created','2026-02-24 12:05:00'),
(49,1,'delivered','Shipment delivered successfully','2026-02-25 17:00:00'),

(50,5,'created','Shipment created','2026-02-25 13:05:00'),
(50,2,'in_transit','Shipment in transit','2026-02-26 10:00:00'),

(51,1,'created','Shipment created','2026-02-26 09:05:00'),
(51,5,'delivered','Shipment delivered successfully','2026-02-27 15:00:00'),

(52,2,'created','Shipment created','2026-02-27 10:05:00'),
(52,3,'in_transit','Shipment in transit','2026-02-28 10:00:00'),

(53,3,'created','Shipment created','2026-02-28 11:05:00'),
(53,4,'delivered','Shipment delivered successfully','2026-03-01 16:00:00'),

(54,4,'created','Shipment created','2026-03-01 09:35:00'),
(54,5,'delivered','Shipment delivered successfully','2026-03-02 15:00:00'),

(55,5,'created','Shipment created','2026-03-02 12:05:00'),
(55,5,'cancelled','Shipment cancelled','2026-03-03 09:00:00'),

(56,1,'created','Shipment created','2026-03-03 08:35:00'),
(56,3,'delivered','Shipment delivered successfully','2026-03-04 16:00:00'),

(57,2,'created','Shipment created','2026-03-04 14:05:00'),
(57,4,'received','Shipment received at destination branch','2026-03-05 10:00:00'),

(58,3,'created','Shipment created','2026-03-05 09:05:00'),
(58,5,'delivered','Shipment delivered successfully','2026-03-06 15:00:00'),

(59,4,'created','Shipment created','2026-03-06 10:35:00'),
(59,2,'in_transit','Shipment in transit','2026-03-07 09:00:00'),

(60,5,'created','Shipment created','2026-03-07 13:05:00'),
(60,4,'delivered','Shipment delivered successfully','2026-03-08 16:00:00');
-- ============================================
--   40 دفعة لجدول ال payments ادخال
-- ============================================

INSERT INTO payments
(shipment_id, amount, payment_method, payment_date, transaction_reference, status)
VALUES

(1,150.00,'card','2026-01-05 10:00:00','TXN100001','successful'),
(2,220.00,'cash','2026-01-06 11:00:00','TXN100002','successful'),
(3,180.00,'bank_transfer','2026-01-07 09:30:00','TXN100003','successful'),
(4,350.00,'card','2026-01-08 12:00:00','TXN100004','successful'),
(5,125.00,'cash','2026-01-09 14:00:00','TXN100005','successful'),

(6,275.00,'pix','2026-01-10 10:15:00','TXN100006','successful'),
(7,410.00,'card','2026-01-11 13:00:00','TXN100007','successful'),
(8,195.00,'cash','2026-01-12 15:00:00','TXN100008','successful'),
(9,320.00,'bank_transfer','2026-01-13 09:45:00','TXN100009','successful'),
(10,150.00,'card','2026-01-14 11:30:00','TXN100010','successful'),

(11,285.00,'cash','2026-01-16 10:00:00','TXN100011','successful'),
(12,375.00,'card','2026-01-17 12:30:00','TXN100012','successful'),
(13,210.00,'pix','2026-01-18 14:00:00','TXN100013','successful'),
(14,450.00,'bank_transfer','2026-01-19 10:30:00','TXN100014','successful'),
(15,175.00,'cash','2026-01-20 13:15:00','TXN100015','successful'),

(16,290.00,'card','2026-01-21 09:30:00','TXN100016','successful'),
(17,330.00,'pix','2026-01-22 11:00:00','TXN100017','successful'),
(18,260.00,'cash','2026-01-23 14:30:00','TXN100018','successful'),
(19,520.00,'card','2026-01-24 16:00:00','TXN100019','successful'),
(20,195.00,'bank_transfer','2026-01-25 10:15:00','TXN100020','successful'),

(21,240.00,'cash','2026-01-26 11:30:00','TXN100021','successful'),
(22,310.00,'card','2026-01-27 13:00:00','TXN100022','successful'),
(23,275.00,'pix','2026-01-28 09:45:00','TXN100023','successful'),
(24,390.00,'bank_transfer','2026-01-29 12:00:00','TXN100024','successful'),
(25,160.00,'cash','2026-01-30 15:00:00','TXN100025','successful'),

(26,285.00,'card','2026-02-02 10:30:00','TXN100026','successful'),
(27,340.00,'pix','2026-02-03 11:45:00','TXN100027','successful'),
(28,225.00,'cash','2026-02-04 13:30:00','TXN100028','successful'),
(29,470.00,'card','2026-02-05 15:15:00','TXN100029','successful'),
(30,180.00,'bank_transfer','2026-02-06 09:30:00','TXN100030','successful'),

(31,300.00,'cash','2026-02-07 10:00:00','TXN100031','successful'),
(32,260.00,'card','2026-02-08 12:15:00','TXN100032','successful'),
(33,350.00,'pix','2026-02-09 14:00:00','TXN100033','failed'),
(34,420.00,'bank_transfer','2026-02-10 16:00:00','TXN100034','successful'),
(35,200.00,'cash','2026-02-11 10:30:00','TXN100035','failed'),

(36,275.00,'card','2026-02-12 11:45:00','TXN100036','successful'),
(37,315.00,'pix','2026-02-13 13:15:00','TXN100037','refunded'),
(38,450.00,'bank_transfer','2026-02-14 15:00:00','TXN100038','successful'),
(39,190.00,'cash','2026-02-15 09:30:00','TXN100039','failed'),
(40,500.00,'card','2026-02-16 12:00:00','TXN100040','successful');


-- ============================================
-- VIEWS
-- ============================================

-- ============================================
-- 1. active_shipments_view
-- ============================================

CREATE OR REPLACE VIEW active_shipments_view AS
SELECT
    s.id,
    s.tracking_number,
    c.full_name AS customer_name,
    ob.branch_name AS origin_branch,
    db.branch_name AS destination_branch,
    s.sender_name,
    s.receiver_name,
    s.receiver_city,
    s.weight,
    s.shipping_cost,
    s.created_at,
    s.expected_delivery_date,
    s.payment_status,
    s.shipment_status
FROM shipments s
JOIN customers c
    ON s.customer_id = c.id
JOIN branches ob
    ON s.origin_branch_id = ob.id
JOIN branches db
    ON s.destination_branch_id = db.id
WHERE s.shipment_status NOT IN
    ('delivered', 'cancelled', 'returned');


-- ============================================
-- 2. driver_performance_view
-- ============================================

CREATE OR REPLACE VIEW driver_performance_view AS
SELECT
    d.id AS driver_id,
    d.full_name AS driver_name,

    COUNT(del.id) AS total_deliveries,

    (
        SELECT COUNT(*)
        FROM deliveries d2
        WHERE d2.driver_id = d.id
          AND d2.delivery_status = 'completed'
    ) AS successful_deliveries,

    (
        SELECT COUNT(*)
        FROM deliveries d3
        WHERE d3.driver_id = d.id
          AND d3.delivery_status <> 'completed'
    ) AS unsuccessful_deliveries,

    (
        SELECT SUM(s.shipping_cost)
        FROM deliveries d4
        JOIN shipments s
            ON d4.shipment_id = s.id
        WHERE d4.driver_id = d.id
    ) AS total_shipment_value,

    (
        SELECT MAX(d5.completed_at)
        FROM deliveries d5
        WHERE d5.driver_id = d.id
    ) AS last_delivery

FROM drivers d
LEFT JOIN deliveries del
    ON d.id = del.driver_id

GROUP BY
    d.id,
    d.full_name;


-- ============================================
-- 3. customer_statistics_view
-- ============================================

CREATE OR REPLACE VIEW customer_statistics_view AS
SELECT
    c.id AS customer_id,
    c.full_name AS customer_name,
    c.email,
    c.phone,
    c.customer_type,
    c.city,

    COUNT(s.id) AS shipment_count,

    SUM(s.shipping_cost) AS total_shipping_cost,

    (
        SELECT COUNT(*)
        FROM shipments s2
        WHERE s2.customer_id = c.id
          AND s2.shipment_status = 'delivered'
    ) AS completed_shipments,

    (
        SELECT COUNT(*)
        FROM shipments s3
        WHERE s3.customer_id = c.id
          AND s3.shipment_status = 'cancelled'
    ) AS cancelled_shipments,

    (
        SELECT MAX(s4.created_at)
        FROM shipments s4
        WHERE s4.customer_id = c.id
    ) AS last_shipment

FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id

GROUP BY
    c.id,
    c.full_name,
    c.email,
    c.phone,
    c.customer_type,
    c.city;


-- ============================================
-- INDEXES
-- ============================================


-- ============================================
-- 1. tracking_number
-- ============================================

-- tracking_number is already UNIQUE.
-- Therefore MySQL already has a UNIQUE INDEX on this column.
-- Creating another normal index would be redundant and unnecessary.

EXPLAIN
SELECT *
FROM shipments
WHERE tracking_number = 'TRK-100001';

-- Expected:
-- type = const
-- key = tracking_number
-- rows = 1

-- Conclusion:
-- The existing UNIQUE index is sufficient.
-- No additional index is required.


-- ============================================
-- 2. customer_id
-- ============================================

-- customer_id is a FOREIGN KEY.
-- In InnoDB, MySQL automatically creates an index
-- if a suitable index does not already exist.
-- Therefore, an additional index is unnecessary.

EXPLAIN
SELECT *
FROM shipments
WHERE customer_id = 1;

-- Expected:
-- type = ref
-- key = customer_id
-- rows = approximately the number of matching shipments

-- Conclusion:
-- The existing index is sufficient.
-- No additional index is required.


-- ============================================
-- 3. shipment_status
-- ============================================

CREATE INDEX idx_shipments_status
ON shipments(shipment_status);

EXPLAIN
SELECT *
FROM shipments
WHERE shipment_status = 'delivered';

-- Before Index:
-- type = ALL
-- key = NULL
-- rows = 60

-- After Index:
-- type = ref
-- key = idx_shipments_status
-- rows = approximately the number of matching rows

-- Conclusion:
-- The index can help MySQL locate shipments
-- with a specific status without scanning the entire table.


-- ============================================
-- 4. created_at
-- ============================================

CREATE INDEX idx_shipments_created_at
ON shipments(created_at);

EXPLAIN
SELECT *
FROM shipments
WHERE created_at >= '2026-02-01';

-- On a small table, MySQL may still choose:
-- type = ALL
-- key = NULL

-- This does NOT mean the index is broken.
-- MySQL may consider a full table scan cheaper
-- when the table is small or the condition matches many rows.

-- Conclusion:
-- The index can become useful as the table grows
-- or when the query filters a smaller range of dates.


-- ============================================
-- 5. expected_delivery_date
-- ============================================

CREATE INDEX idx_shipments_expected_delivery
ON shipments(expected_delivery_date);

EXPLAIN
SELECT *
FROM shipments
WHERE expected_delivery_date <= '2026-03-01';

-- MySQL may choose:
-- type = ALL
-- key = NULL
-- even though the index exists.

-- possible_keys may show:
-- idx_shipments_expected_delivery

-- Conclusion:
-- The index exists and is available,
-- but MySQL may choose a full table scan
-- if it estimates that it is more efficient.


-- ============================================
-- 6. driver_id
-- ============================================

-- driver_id is a FOREIGN KEY.
-- MySQL already has a suitable index for the FK
-- if one was not previously created.
-- Therefore, an additional index is unnecessary.

EXPLAIN
SELECT *
FROM deliveries
WHERE driver_id = 1;

-- Expected:
-- type = ref
-- key = driver_id

-- Conclusion:
-- The existing index is sufficient.
-- No additional index is required.


-- ============================================
-- 7. payment_date
-- ============================================

CREATE INDEX idx_payments_payment_date
ON payments(payment_date);

EXPLAIN
SELECT *
FROM payments
WHERE payment_date >= '2026-02-01';

-- On the current small table MySQL may choose:
-- type = ALL
-- key = NULL

-- Conclusion:
-- The index exists, but MySQL may prefer
-- a full table scan because the payments table is small.
-- The index can become more useful as the table grows
-- or when the query selects a smaller date range.


-- ============================================
-- WHEN CAN AN EXTRA INDEX BECOME USELESS OR COSTLY?
-- ============================================

-- An additional index may be unnecessary when:
-- 1. The column already has a UNIQUE index.
-- 2. The column is already indexed because of a FOREIGN KEY.
-- 3. Another existing index already supports the same query.
--
-- An index also has a cost:
-- 1. It consumes additional disk/storage space.
-- 2. INSERT operations become slightly more expensive.
-- 3. UPDATE operations become more expensive when indexed
--    columns are modified.
-- 4. DELETE operations also require index maintenance.
-- 5. Too many indexes can make the optimizer's choices
--    more complicated.
--
-- Therefore, indexes should be added based on real queries
-- and performance requirements, not simply added to every column.


-- ============================================
-- TRANSACTION
-- ============================================

-- A transaction groups multiple SQL operations
-- into one logical unit.

-- START TRANSACTION:
-- Starts the transaction.

-- COMMIT:
-- Permanently saves all changes.

-- ROLLBACK:
-- Cancels all changes made during the transaction.


-- ============================================
-- Example: Create Shipment + Tracking + Payment
-- ============================================

START TRANSACTION;


-- 1. Create a new shipment

INSERT INTO shipments
(
    tracking_number,
    customer_id,
    origin_branch_id,
    destination_branch_id,
    sender_name,
    sender_phone,
    receiver_name,
    receiver_phone,
    receiver_address,
    receiver_city,
    weight,
    shipping_cost,
    expected_delivery_date,
    payment_status,
    shipment_status
)
VALUES
(
    CONCAT('TRX-', UUID_SHORT()),
    1,
    1,
    2,
    'Ahmad Hassan',
    '0501000001',
    'Sara Omar',
    '0501000002',
    'Kadikoy, Istanbul',
    'Istanbul',
    5.00,
    200.00,
    '2026-10-15',
    'pending',
    'created'
);


-- Save the new shipment ID

SET @new_shipment_id = LAST_INSERT_ID();


-- 2. Add the first tracking record

INSERT INTO shipment_tracking
(
    shipment_id,
    branch_id,
    status,
    description,
    recorded_at
)
VALUES
(
    @new_shipment_id,
    1,
    'created',
    'Shipment created successfully',
    NOW()
);


-- 3. Record the payment

INSERT INTO payments
(
    shipment_id,
    amount,
    payment_method,
    payment_date,
    transaction_reference,
    status
)
VALUES
(
    @new_shipment_id,
    200.00,
    'card',
    NOW(),
    CONCAT('PAY-', UUID_SHORT()),
    'successful'
);


-- 4. Save all operations

COMMIT;


-- ============================================
-- ROLLBACK EXAMPLE
-- ============================================

-- If a problem occurs before COMMIT,
-- use:

-- ROLLBACK;



-- ============================================
-- TRANSACTION VERIFICATION
-- ============================================

-- After the transaction, the inserted data can be verified
-- in all three related tables.

SELECT *
FROM shipments
WHERE id = 61;

SELECT *
FROM shipment_tracking
WHERE shipment_id = 61;

SELECT *
FROM payments
WHERE shipment_id = 61;


-- Expected result from the previous transaction:
--
-- Shipment 61 was created.
-- Tracking record 121 was created.
-- Payment record 41 was created.
-- COMMIT permanently saved all changes.


-- ============================================
-- ROLLBACK
-- ============================================

-- ROLLBACK is used when an error occurs
-- or when we want to cancel changes made
-- inside the current transaction.
--
-- All changes made after START TRANSACTION
-- are undone as long as they have not been committed.
--
-- COMMIT makes the changes permanent.
-- ROLLBACK cancels the uncommitted changes.
--
-- Transactions ensure that related operations
-- can be treated as one logical unit,
-- which helps maintain data consistency.


-- ============================================
-- STORED PROCEDURES
-- ============================================

-- In this project, three Stored Procedures are created:
--
-- 1. create_shipment
-- 2. assign_delivery
-- 3. complete_delivery


-- ============================================
-- 1. create_shipment
-- ============================================

DROP PROCEDURE IF EXISTS create_shipment;

DELIMITER //

CREATE PROCEDURE create_shipment(
    IN p_tracking_number VARCHAR(50),
    IN p_customer_id INT,
    IN p_origin_branch_id INT,
    IN p_destination_branch_id INT,
    IN p_sender_name VARCHAR(100),
    IN p_sender_phone VARCHAR(20),
    IN p_receiver_name VARCHAR(100),
    IN p_receiver_phone VARCHAR(20),
    IN p_receiver_address VARCHAR(255),
    IN p_receiver_city VARCHAR(100),
    IN p_weight DECIMAL(10,2),
    IN p_shipping_cost DECIMAL(10,2),
    IN p_expected_delivery_date DATE
)
BEGIN

    DECLARE v_shipment_id INT;

    INSERT INTO shipments (
        tracking_number,
        customer_id,
        origin_branch_id,
        destination_branch_id,
        sender_name,
        sender_phone,
        receiver_name,
        receiver_phone,
        receiver_address,
        receiver_city,
        weight,
        shipping_cost,
        expected_delivery_date
    )
    VALUES (
        p_tracking_number,
        p_customer_id,
        p_origin_branch_id,
        p_destination_branch_id,
        p_sender_name,
        p_sender_phone,
        p_receiver_name,
        p_receiver_phone,
        p_receiver_address,
        p_receiver_city,
        p_weight,
        p_shipping_cost,
        p_expected_delivery_date
    );

    SET v_shipment_id = LAST_INSERT_ID();

    INSERT INTO shipment_tracking (
        shipment_id,
        branch_id,
        status,
        description,
        recorded_at
    )
    VALUES (
        v_shipment_id,
        p_origin_branch_id,
        'created',
        'Shipment created',
        NOW()
    );

END //

DELIMITER ;


-- ============================================
-- TEST create_shipment
-- ============================================

CALL create_shipment(
    'TRK100063',
    1,
    1,
    2,
    'Omar Ali',
    '0502000002',
    'Lina Ali',
    '0506000002',
    'Kadikoy',
    'Istanbul',
    3.00,
    200.00,
    '2026-10-07'
);


-- Verify the newly created shipment

SELECT *
FROM shipments
WHERE tracking_number = 'TRK100063';

SELECT *
FROM shipment_tracking
WHERE shipment_id = (
    SELECT id
    FROM shipments
    WHERE tracking_number = 'TRK100063'
);


-- ============================================
-- 2. assign_delivery
-- ============================================

DROP PROCEDURE IF EXISTS assign_delivery;

DELIMITER //

CREATE PROCEDURE assign_delivery(
    IN p_shipment_id INT,
    IN p_driver_id INT,
    IN p_vehicle_id INT
)
BEGIN

    DECLARE v_delivery_exists INT DEFAULT 0;
    DECLARE v_driver_status VARCHAR(30);
    DECLARE v_vehicle_status VARCHAR(30);
    DECLARE v_shipment_status VARCHAR(30);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Check shipment status

    SELECT shipment_status
    INTO v_shipment_status
    FROM shipments
    WHERE id = p_shipment_id;

    IF v_shipment_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipment not found';
    END IF;

    IF v_shipment_status <> 'created' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipment is not available for delivery assignment';
    END IF;


    -- Check driver status

    SELECT status
    INTO v_driver_status
    FROM drivers
    WHERE id = p_driver_id;

    IF v_driver_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver not found';
    END IF;

    IF v_driver_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver is not active';
    END IF;


    -- Check vehicle status

    SELECT status
    INTO v_vehicle_status
    FROM vehicles
    WHERE id = p_vehicle_id;

    IF v_vehicle_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehicle not found';
    END IF;

    IF v_vehicle_status <> 'available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehicle is not available';
    END IF;


    -- Check whether this shipment already has a delivery

    SELECT COUNT(*)
    INTO v_delivery_exists
    FROM deliveries
    WHERE shipment_id = p_shipment_id;

    IF v_delivery_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipment already has a delivery';
    END IF;


    -- Create delivery

    INSERT INTO deliveries (
        shipment_id,
        driver_id,
        vehicle_id,
        delivery_status,
        started_at,
        completed_at
    )
    VALUES (
        p_shipment_id,
        p_driver_id,
        p_vehicle_id,
        'assigned',
        NULL,
        NULL
    );


    -- Update shipment status

    UPDATE shipments
    SET shipment_status = 'assigned'
    WHERE id = p_shipment_id;


    -- Update vehicle status

    UPDATE vehicles
    SET status = 'assigned'
    WHERE id = p_vehicle_id;


    -- Add tracking record

    INSERT INTO shipment_tracking (
        shipment_id,
        branch_id,
        status,
        description,
        recorded_at
    )
    SELECT
        s.id,
        s.origin_branch_id,
        'assigned',
        'Shipment assigned for delivery',
        NOW()
    FROM shipments s
    WHERE s.id = p_shipment_id;


    COMMIT;

END //

DELIMITER ;


-- ============================================
-- TEST assign_delivery
-- ============================================

-- Example:
--
-- CALL assign_delivery(
--     61,
--     1,
--     1
-- );


-- ============================================
-- 3. complete_delivery
-- ============================================

DROP PROCEDURE IF EXISTS complete_delivery;

DELIMITER //

CREATE PROCEDURE complete_delivery(
    IN p_delivery_id INT
)
BEGIN

    DECLARE v_shipment_id INT DEFAULT NULL;
    DECLARE v_vehicle_id INT DEFAULT NULL;
    DECLARE v_destination_branch_id INT DEFAULT NULL;
    DECLARE v_delivery_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;


    START TRANSACTION;


    -- Find the delivery and its shipment

    SELECT COUNT(*)
    INTO v_delivery_count
    FROM deliveries d
    JOIN shipments s
        ON d.shipment_id = s.id
    WHERE d.id = p_delivery_id
      AND d.delivery_status IN ('assigned', 'in_progress');


    IF v_delivery_count = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Delivery is not available for completion';

    END IF;


    -- Get the required IDs

    SELECT
        d.shipment_id,
        d.vehicle_id,
        s.destination_branch_id
    INTO
        v_shipment_id,
        v_vehicle_id,
        v_destination_branch_id
    FROM deliveries d
    JOIN shipments s
        ON d.shipment_id = s.id
    WHERE d.id = p_delivery_id
      AND d.delivery_status IN ('assigned', 'in_progress')
    LIMIT 1;


    -- Complete delivery

    UPDATE deliveries
    SET
        started_at = IFNULL(started_at, NOW()),
        completed_at = NOW(),
        delivery_status = 'completed'
    WHERE id = p_delivery_id;


    -- Update shipment

    UPDATE shipments
    SET
        shipment_status = 'delivered',
        delivered_at = NOW()
    WHERE id = v_shipment_id;


    -- Add tracking record

    INSERT INTO shipment_tracking (
        shipment_id,
        branch_id,
        status,
        description,
        recorded_at
    )
    VALUES (
        v_shipment_id,
        v_destination_branch_id,
        'delivered',
        'Shipment delivered successfully',
        NOW()
    );


    -- Make vehicle available again

    UPDATE vehicles
    SET status = 'available'
    WHERE id = v_vehicle_id;


    COMMIT;

END //

DELIMITER ;


-- ============================================
-- TEST complete_delivery
-- ============================================

-- Example:
--
-- CALL complete_delivery(1);


-- Verify delivery

-- SELECT *
-- FROM deliveries
-- WHERE id = 1;

-- Verify shipment

-- SELECT *
-- FROM shipments
-- WHERE id = (
--     SELECT shipment_id
--     FROM deliveries
--     WHERE id = 1
-- );

-- Verify tracking

-- SELECT *
-- FROM shipment_tracking
-- WHERE shipment_id = (
--     SELECT shipment_id
--     FROM deliveries
--     WHERE id = 1
-- );



-- ================================================
-- ================== TRIGGERS ====================
-- ================================================


-- ================================================
-- 1. Update Shipment Status from Tracking
-- ================================================

DROP TRIGGER IF EXISTS update_shipment_status_from_tracking;

DELIMITER //

CREATE TRIGGER update_shipment_status_from_tracking
AFTER INSERT
ON shipment_tracking
FOR EACH ROW
BEGIN

    UPDATE shipments
    SET shipment_status = NEW.status
    WHERE id = NEW.shipment_id;

END //

DELIMITER ;


-- ================================================
-- 2. Update Vehicle Status When Delivery Starts
-- ================================================

DROP TRIGGER IF EXISTS update_vehicle_status_on_delivery_start;

DELIMITER //

CREATE TRIGGER update_vehicle_status_on_delivery_start
AFTER UPDATE
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status = 'in_progress'
       AND OLD.delivery_status <> 'in_progress' THEN

        UPDATE vehicles
        SET status = 'in_delivery'
        WHERE id = NEW.vehicle_id;

    END IF;

END //

DELIMITER ;


-- ================================================
-- 3. Update Vehicle Status When Delivery Completes
-- ================================================

DROP TRIGGER IF EXISTS update_vehicle_status_on_delivery_complete;

DELIMITER //

CREATE TRIGGER update_vehicle_status_on_delivery_complete
AFTER UPDATE
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status = 'completed'
       AND OLD.delivery_status <> 'completed' THEN

        UPDATE vehicles
        SET status = 'available'
        WHERE id = NEW.vehicle_id;

    END IF;

END //

DELIMITER ;




-- ================================================
-- 4. Prevent Invalid Payments
-- ================================================

DROP TRIGGER IF EXISTS prevent_invalid_payment;

DELIMITER //

CREATE TRIGGER prevent_invalid_payment
BEFORE INSERT
ON payments
FOR EACH ROW
BEGIN

    IF NEW.amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Payment amount must be greater than 0';

    END IF;

END //

DELIMITER ;


-- ================================================
-- 5. Prevent Deleting Customers with Shipments
-- ================================================

DROP TRIGGER IF EXISTS prevent_customer_delete_with_shipments;

DELIMITER //

CREATE TRIGGER prevent_customer_delete_with_shipments
BEFORE DELETE
ON customers
FOR EACH ROW
BEGIN

    IF EXISTS (
        SELECT 1
        FROM shipments
        WHERE customer_id = OLD.id
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Cannot delete customer with shipments';

    END IF;

END //

DELIMITER ;


-- ================================================
-- 6. Prevent Invalid Delivery Completion
-- ================================================

DROP TRIGGER IF EXISTS prevent_invalid_delivery_completion;

DELIMITER //

CREATE TRIGGER prevent_invalid_delivery_completion
BEFORE UPDATE
ON deliveries
FOR EACH ROW
BEGIN

    DECLARE v_shipment_status VARCHAR(30);

    IF NEW.delivery_status = 'completed'
       AND OLD.delivery_status <> 'completed' THEN

        SELECT shipment_status
        INTO v_shipment_status
        FROM shipments
        WHERE id = NEW.shipment_id;

        IF v_shipment_status IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Shipment does not exist';

        END IF;

        IF v_shipment_status IN
           ('created', 'cancelled', 'returned') THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Cannot complete delivery for this shipment status';

        END IF;

    END IF;

END //

DELIMITER ;


-- ================================================
-- 7. Prevent Multiple Active Deliveries
--    for the Same Vehicle
-- ================================================

DROP TRIGGER IF EXISTS prevent_vehicle_multiple_active_deliveries;

DELIMITER //

CREATE TRIGGER prevent_vehicle_multiple_active_deliveries
BEFORE INSERT
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status IN ('assigned', 'in_progress')
       AND EXISTS (
            SELECT 1
            FROM deliveries
            WHERE vehicle_id = NEW.vehicle_id
              AND delivery_status IN ('assigned', 'in_progress')
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Vehicle already has an active delivery';

    END IF;

END //

DELIMITER ;


-- ================================================
-- 7-B. Prevent Vehicle Conflict on UPDATE
-- ================================================

DROP TRIGGER IF EXISTS prevent_vehicle_multiple_active_deliveries_update;

DELIMITER //

CREATE TRIGGER prevent_vehicle_multiple_active_deliveries_update
BEFORE UPDATE
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status IN ('assigned', 'in_progress') THEN

        IF EXISTS (
            SELECT 1
            FROM deliveries
            WHERE vehicle_id = NEW.vehicle_id
              AND delivery_status IN ('assigned', 'in_progress')
              AND id <> NEW.id
        ) THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Vehicle already has an active delivery';

        END IF;

    END IF;

END //

DELIMITER ;


-- ================================================
-- 8. Prevent Multiple Active Deliveries
--    for the Same Driver
-- ================================================

DROP TRIGGER IF EXISTS prevent_driver_multiple_active_deliveries;

DELIMITER //

CREATE TRIGGER prevent_driver_multiple_active_deliveries
BEFORE INSERT
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status IN ('assigned', 'in_progress')
       AND EXISTS (
            SELECT 1
            FROM deliveries
            WHERE driver_id = NEW.driver_id
              AND delivery_status IN ('assigned', 'in_progress')
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Driver already has an active delivery';

    END IF;

END //

DELIMITER ;


-- ================================================
-- 8-B. Prevent Driver Conflict on UPDATE
-- ================================================

DROP TRIGGER IF EXISTS prevent_driver_multiple_active_deliveries_update;

DELIMITER //

CREATE TRIGGER prevent_driver_multiple_active_deliveries_update
BEFORE UPDATE
ON deliveries
FOR EACH ROW
BEGIN

    IF NEW.delivery_status IN ('assigned', 'in_progress') THEN

        IF EXISTS (
            SELECT 1
            FROM deliveries
            WHERE driver_id = NEW.driver_id
              AND delivery_status IN ('assigned', 'in_progress')
              AND id <> NEW.id
        ) THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Driver already has an active delivery';

        END IF;

    END IF;

END //

DELIMITER ;


-- ================================================
-- 9. Prevent Tracking Before Shipment Creation
-- ================================================

DROP TRIGGER IF EXISTS prevent_tracking_before_shipment;

DELIMITER //

CREATE TRIGGER prevent_tracking_before_shipment
BEFORE INSERT
ON shipment_tracking
FOR EACH ROW
BEGIN

    DECLARE v_created_at DATETIME;

    SELECT created_at
    INTO v_created_at
    FROM shipments
    WHERE id = NEW.shipment_id;

    IF v_created_at IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Shipment does not exist';

    END IF;

    IF NEW.recorded_at < v_created_at THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Tracking date cannot be earlier than shipment creation';

    END IF;

END //

DELIMITER ;


-- ================================================
-- 10. Prevent Overweight Shipment Delivery
-- ================================================

DROP TRIGGER IF EXISTS prevent_overweight_shipment_delivery;

DELIMITER //

CREATE TRIGGER prevent_overweight_shipment_delivery
BEFORE INSERT
ON deliveries
FOR EACH ROW
BEGIN

    DECLARE v_shipment_weight DECIMAL(10,2);
    DECLARE v_vehicle_capacity DECIMAL(10,2);

    SELECT weight
    INTO v_shipment_weight
    FROM shipments
    WHERE id = NEW.shipment_id;

    SELECT max_weight
    INTO v_vehicle_capacity
    FROM vehicles
    WHERE id = NEW.vehicle_id;


    IF v_shipment_weight IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Shipment does not exist';

    END IF;


    IF v_vehicle_capacity IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Vehicle does not exist';

    END IF;


    IF v_shipment_weight > v_vehicle_capacity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Shipment weight exceeds vehicle capacity';

    END IF;

END //

DELIMITER ;





-- ======================================================
-- ================== Advanced Queries ==================
-- ======================================================


-- ======================================================
-- 1. Customers whose spending is higher than
--    the average spending of all customers
-- ======================================================

SELECT
    c.id,
    c.full_name,
    COALESCE(SUM(p.amount), 0) AS total_spending
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
   AND p.status = 'successful'
GROUP BY
    c.id,
    c.full_name
HAVING COALESCE(SUM(p.amount), 0) > (
    SELECT AVG(customer_spending)
    FROM (
        SELECT
            c2.id,
            COALESCE(SUM(p2.amount), 0) AS customer_spending
        FROM customers c2
        LEFT JOIN shipments s2
            ON c2.id = s2.customer_id
        LEFT JOIN payments p2
            ON s2.id = p2.shipment_id
           AND p2.status = 'successful'
        GROUP BY
            c2.id
    ) AS spending_table
);


-- ======================================================
-- 2. Employees whose salary is higher than
--    the average salary of their branch
-- ======================================================

SELECT
    e.id,
    e.full_name,
    e.branch_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.branch_id = e.branch_id
);


-- ======================================================
-- 3. Shipments whose shipping cost is higher than
--    the average shipping cost of all shipments
-- ======================================================

SELECT
    id,
    tracking_number,
    shipping_cost
FROM shipments
WHERE shipping_cost > (
    SELECT AVG(shipping_cost)
    FROM shipments
);


-- ======================================================
-- 4. Drivers whose number of deliveries is higher
--    than the average number of deliveries per driver
-- ======================================================

SELECT
    d.id,
    d.full_name,
    COUNT(del.id) AS delivery_count
FROM drivers d
LEFT JOIN deliveries del
    ON d.id = del.driver_id
GROUP BY
    d.id,
    d.full_name
HAVING COUNT(del.id) > (
    SELECT AVG(driver_delivery_count)
    FROM (
        SELECT
            d2.id,
            COUNT(del2.id) AS driver_delivery_count
        FROM drivers d2
        LEFT JOIN deliveries del2
            ON d2.id = del2.driver_id
        GROUP BY
            d2.id
    ) AS driver_counts
);


-- ======================================================
-- 5. Branches whose revenue is higher than
--    the average revenue of all branches
-- ======================================================

SELECT
    b.id,
    b.branch_name,
    COALESCE(SUM(p.amount), 0) AS branch_revenue
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.origin_branch_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
   AND p.status = 'successful'
GROUP BY
    b.id,
    b.branch_name
HAVING COALESCE(SUM(p.amount), 0) > (
    SELECT AVG(branch_revenue)
    FROM (
        SELECT
            b2.id,
            COALESCE(SUM(p2.amount), 0) AS branch_revenue
        FROM branches b2
        LEFT JOIN shipments s2
            ON b2.id = s2.origin_branch_id
        LEFT JOIN payments p2
            ON s2.id = p2.shipment_id
           AND p2.status = 'successful'
        GROUP BY
            b2.id
    ) AS branch_revenues
);


-- ======================================================
-- 6. Vehicles used more than the average usage
--    of all vehicles
-- ======================================================

SELECT
    v.id,
    v.plate_number,
    COUNT(d.id) AS usage_count
FROM vehicles v
LEFT JOIN deliveries d
    ON v.id = d.vehicle_id
GROUP BY
    v.id,
    v.plate_number
HAVING COUNT(d.id) > (
    SELECT AVG(vehicle_usage)
    FROM (
        SELECT
            v2.id,
            COUNT(d2.id) AS vehicle_usage
        FROM vehicles v2
        LEFT JOIN deliveries d2
            ON v2.id = d2.vehicle_id
        GROUP BY
            v2.id
    ) AS vehicle_usage_table
);


-- ====================================================
-- ================= WINDOW FUNCTIONS =================
-- ====================================================


-- 1. ترتيب العملاء حسب إجمالي الإنفاق — RANK()
SELECT
    c.id,
    c.full_name,
    COALESCE(SUM(p.amount), 0) AS total_spending,
    RANK() OVER (
        ORDER BY COALESCE(SUM(p.amount), 0) DESC
    ) AS spending_rank
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
   AND p.status = 'successful'
GROUP BY
    c.id,
    c.full_name
ORDER BY
    spending_rank;


-- 2. ترتيب السائقين حسب عدد التوصيلات — DENSE_RANK()
SELECT
    d.id,
    d.full_name,
    COUNT(del.id) AS delivery_count,
    DENSE_RANK() OVER (
        ORDER BY COUNT(del.id) DESC
    ) AS delivery_rank
FROM drivers d
LEFT JOIN deliveries del
    ON d.id = del.driver_id
GROUP BY
    d.id,
    d.full_name
ORDER BY
    delivery_rank;


-- 3. ترتيب الموظفين حسب الراتب داخل كل فرع — ROW_NUMBER()
SELECT
    e.id,
    e.full_name,
    e.branch_id,
    e.salary,
    ROW_NUMBER() OVER (
        PARTITION BY e.branch_id
        ORDER BY e.salary DESC
    ) AS salary_rank
FROM employees e
ORDER BY
    e.branch_id,
    salary_rank;


-- 4. أعلى 3 موظفين راتبًا في كل فرع
SELECT
    id,
    full_name,
    branch_id,
    salary,
    salary_rank
FROM (
    SELECT
        e.id,
        e.full_name,
        e.branch_id,
        e.salary,
        ROW_NUMBER() OVER (
            PARTITION BY e.branch_id
            ORDER BY e.salary DESC
        ) AS salary_rank
    FROM employees e
) AS ranked_employees
WHERE salary_rank <= 3
ORDER BY
    branch_id,
    salary_rank;


-- 5. الإيراد الشهري التراكمي
SELECT
    YEAR(payment_date) AS payment_year,
    MONTH(payment_date) AS month_number,
    MONTHNAME(payment_date) AS month_name,
    SUM(amount) AS monthly_revenue,
    SUM(SUM(amount)) OVER (
        ORDER BY YEAR(payment_date), MONTH(payment_date)
    ) AS cumulative_revenue
FROM payments
WHERE status = 'successful'
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date),
    MONTHNAME(payment_date)
ORDER BY
    payment_year,
    month_number;


-- 6. مقارنة إيراد كل شهر مع الشهر السابق — LAG()
WITH monthly_revenue AS (
    SELECT
        YEAR(payment_date) AS payment_year,
        MONTH(payment_date) AS month_number,
        MONTHNAME(payment_date) AS month_name,
        SUM(amount) AS monthly_revenue
    FROM payments
    WHERE status = 'successful'
    GROUP BY
        YEAR(payment_date),
        MONTH(payment_date),
        MONTHNAME(payment_date)
)
SELECT
    payment_year,
    month_number,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY payment_year, month_number
    ) AS previous_month_revenue,
    monthly_revenue -
    LAG(monthly_revenue) OVER (
        ORDER BY payment_year, month_number
    ) AS revenue_difference
FROM monthly_revenue
ORDER BY
    payment_year,
    month_number;


-- 7. الفرق بين كل دفعة والدفعة السابقة
SELECT
    id AS payment_id,
    shipment_id,
    payment_date,
    amount,
    LAG(amount) OVER (
        ORDER BY payment_date, id
    ) AS previous_payment_amount,
    amount -
    LAG(amount) OVER (
        ORDER BY payment_date, id
    ) AS payment_difference
FROM payments
ORDER BY
    payment_date,
    id;


-- 8. أول وآخر Tracking لكل شحنة
SELECT
    shipment_id,
    status,
    recorded_at,
    FIRST_VALUE(status) OVER (
        PARTITION BY shipment_id
        ORDER BY recorded_at
    ) AS first_tracking_status,
    LAST_VALUE(status) OVER (
        PARTITION BY shipment_id
        ORDER BY recorded_at
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS last_tracking_status
FROM shipment_tracking
ORDER BY
    shipment_id,
    recorded_at;


-- 9. رقم تسلسلي لحركة الشحنة
SELECT
    shipment_id,
    status,
    branch_id,
    recorded_at,
    ROW_NUMBER() OVER (
        PARTITION BY shipment_id
        ORDER BY recorded_at
    ) AS movement_number
FROM shipment_tracking
ORDER BY
    shipment_id,
    movement_number;


-- 10. مساهمة كل عميل كنسبة من إجمالي إيرادات الشركة
SELECT
    c.id,
    c.full_name,
    COALESCE(SUM(p.amount), 0) AS customer_revenue,
    COALESCE(SUM(p.amount), 0) * 100.0 /
    NULLIF(SUM(SUM(p.amount)) OVER (), 0) AS contribution_percentage
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
   AND p.status = 'successful'
GROUP BY
    c.id,
    c.full_name
ORDER BY
    contribution_percentage DESC;


-- ====================================================
-- ====================== CTE =========================
-- ====================================================


-- 1. CTE 1 — العملاء الذين إنفاقهم أعلى من المتوسط
WITH customer_spending AS (
    SELECT
        c.id,
        c.full_name,
        COALESCE(SUM(p.amount), 0) AS total_spending
    FROM customers c
    LEFT JOIN shipments s
        ON c.id = s.customer_id
    LEFT JOIN payments p
        ON s.id = p.shipment_id
       AND p.status = 'successful'
    GROUP BY
        c.id,
        c.full_name
)
SELECT
    id,
    full_name,
    total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY
    total_spending DESC;


-- 2. CTE 2 — أداء الفروع: عدد الشحنات + الإيرادات
WITH branch_performance AS (
    SELECT
        b.id,
        b.branch_name,
        COUNT(DISTINCT s.id) AS shipment_count,
        COALESCE(
            SUM(
                CASE
                    WHEN p.status = 'successful' THEN p.amount
                    ELSE 0
                END
            ),
            0
        ) AS revenue
    FROM branches b
    LEFT JOIN shipments s
        ON b.id = s.origin_branch_id
    LEFT JOIN payments p
        ON s.id = p.shipment_id
    GROUP BY
        b.id,
        b.branch_name
)
SELECT
    id,
    branch_name,
    shipment_count,
    revenue
FROM branch_performance
ORDER BY
    revenue DESC;


-- 3. CTE 3 — الـ Overdue Shipments مع اسم العميل والسائق الحالي
WITH overdue_shipments AS (
    SELECT
        s.id,
        s.tracking_number,
        c.full_name AS customer_name,
        s.expected_delivery_date,
        d.full_name AS driver_name
    FROM shipments s
    JOIN customers c
        ON s.customer_id = c.id
    LEFT JOIN deliveries del
        ON s.id = del.shipment_id
       AND del.delivery_status IN ('assigned', 'in_progress')
    LEFT JOIN drivers d
        ON del.driver_id = d.id
    WHERE s.expected_delivery_date < CURDATE()
      AND s.shipment_status <> 'delivered'
)
SELECT
    id,
    tracking_number,
    customer_name,
    expected_delivery_date,
    driver_name
FROM overdue_shipments
ORDER BY
    expected_delivery_date;


-- 4. CTE 4 — أداء السائقين فوق المتوسط
WITH driver_performance AS (
    SELECT
        d.id,
        d.full_name,
        COUNT(del.id) AS delivery_count,
        COUNT(
            CASE
                WHEN del.delivery_status = 'completed'
                THEN 1
            END
        ) AS successful_deliveries,
        COALESCE(
            SUM(
                CASE
                    WHEN del.delivery_status = 'completed'
                    THEN s.shipping_cost
                    ELSE 0
                END
            ),
            0
        ) AS total_shipment_value
    FROM drivers d
    LEFT JOIN deliveries del
        ON d.id = del.driver_id
    LEFT JOIN shipments s
        ON del.shipment_id = s.id
    GROUP BY
        d.id,
        d.full_name
)
SELECT
    id,
    full_name,
    delivery_count,
    successful_deliveries,
    total_shipment_value
FROM driver_performance
WHERE successful_deliveries > (
    SELECT AVG(successful_deliveries)
    FROM driver_performance
)
ORDER BY
    successful_deliveries DESC;



-- ==========================================================
-- ============== INTEGRITY & SAFETY CHECKS ================
-- ==========================================================


-- 1. Delivered Shipment Must Have Delivered Date
SELECT
    id,
    tracking_number,
    shipment_status,
    delivered_at
FROM shipments
WHERE
    (shipment_status = 'delivered' AND delivered_at IS NULL)
    OR
    (shipment_status <> 'delivered' AND delivered_at IS NOT NULL);

-- Expected result:
-- 0 rows


-- 2. Shipment Cannot Have Delivered Date Before Delivery
SELECT
    id,
    tracking_number,
    shipment_status,
    delivered_at
FROM shipments
WHERE shipment_status <> 'delivered'
  AND delivered_at IS NOT NULL;

-- Expected result:
-- 0 rows


-- 3. Completed Delivery Cannot Belong to a Created Shipment
SELECT
    d.id AS delivery_id,
    d.shipment_id,
    d.delivery_status,
    s.shipment_status
FROM deliveries d
JOIN shipments s
    ON d.shipment_id = s.id
WHERE d.delivery_status = 'completed'
  AND s.shipment_status = 'created';

-- Expected result:
-- 0 rows


-- 4. A Vehicle Cannot Have Multiple Active Deliveries
SELECT
    vehicle_id,
    COUNT(*) AS active_deliveries
FROM deliveries
WHERE delivery_status IN ('assigned', 'in_progress')
GROUP BY vehicle_id
HAVING COUNT(*) > 1;

-- Expected result:
-- 0 rows


-- 5. A Driver Cannot Have Multiple Active Deliveries
SELECT
    driver_id,
    COUNT(*) AS active_deliveries
FROM deliveries
WHERE delivery_status IN ('assigned', 'in_progress')
GROUP BY driver_id
HAVING COUNT(*) > 1;

-- Expected result:
-- 0 rows


-- 6. Successful Payments Must Reference Existing Shipments
SELECT
    p.id AS payment_id,
    p.shipment_id,
    p.status
FROM payments p
LEFT JOIN shipments s
    ON p.shipment_id = s.id
WHERE p.status = 'successful'
  AND s.id IS NULL;

-- Expected result:
-- 0 rows


-- 7. Tracking Date Cannot Be Before Shipment Creation
SELECT
    st.id AS tracking_id,
    st.shipment_id,
    s.tracking_number,
    s.created_at,
    st.recorded_at
FROM shipment_tracking st
JOIN shipments s
    ON st.shipment_id = s.id
WHERE st.recorded_at < s.created_at;

-- Expected result:
-- 0 rows


-- 8. Shipment Weight Cannot Exceed Vehicle Capacity
SELECT
    d.id AS delivery_id,
    d.shipment_id,
    d.vehicle_id,
    s.weight AS shipment_weight,
    v.max_weight AS vehicle_max_weight
FROM deliveries d
JOIN shipments s
    ON d.shipment_id = s.id
JOIN vehicles v
    ON d.vehicle_id = v.id
WHERE s.weight > v.max_weight;

-- Expected result:
-- 0 rows


-- ============================================================================
-- ========================= NORMALIZATION ================================
-- ============================================================================


-- 1. FUNCTIONAL DEPENDENCIES
-- ============================================================================

-- Functional dependencies describe how one attribute determines
-- other attributes in the database.

-- Examples from the Logistics & Delivery Management System:

-- customer_id → full_name, email, phone, customer_type, city,
--                address, registered_at, status

-- branch_id → branch_name, city, address, phone, manager_name,
--              opened_at, status

-- employee_id → branch_id, full_name, email, phone, job_title,
--               salary, hire_date, status

-- driver_id → branch_id, full_name, phone, license_number,
--              license_expiry_date, hire_date, salary, status

-- vehicle_id → branch_id, plate_number, vehicle_type, model,
--              manufacture_year, max_weight, status

-- shipment_id → tracking_number, customer_id, origin_branch_id,
--                destination_branch_id, sender_name, sender_phone,
--                receiver_name, receiver_phone, receiver_address,
--                receiver_city, weight, shipping_cost, created_at,
--                expected_delivery_date, delivered_at, payment_status,
--                shipment_status

-- delivery_id → shipment_id, driver_id, vehicle_id, assigned_at,
--               started_at, completed_at, delivery_status, notes

-- payment_id → shipment_id, amount, payment_method, payment_date,
--              transaction_reference, status

-- These dependencies show that each entity's primary key
-- determines the attributes belonging to that entity.



-- 2. FIRST NORMAL FORM (1NF)
-- ============================================================================

-- The database satisfies First Normal Form because:

-- • Each table has a primary key.
-- • Each column contains atomic values.
-- • There are no repeating groups.
-- • Multiple values are not stored in a single column.
-- • Each row represents one specific entity or transaction.

-- For example:
-- Customer phone numbers are stored as individual values
-- rather than as a comma-separated list.

-- Therefore, the database satisfies 1NF.



-- 3. SECOND NORMAL FORM (2NF)
-- ============================================================================

-- The database satisfies Second Normal Form because:

-- • It already satisfies 1NF.
-- • The main tables use single-column primary keys such as
--   customer_id, shipment_id, employee_id, and vehicle_id.
-- • There are no partial dependencies where a non-key attribute
--   depends only on part of a composite primary key.

-- Therefore, non-key attributes depend on the complete primary key
-- of their table.

-- The database satisfies 2NF.



-- 4. THIRD NORMAL FORM (3NF)
-- ============================================================================

-- The database satisfies Third Normal Form because:

-- • It satisfies 2NF.
-- • Non-key attributes depend on the primary key of their own table.
-- • Attributes belonging to another entity are stored in that entity's
--   table instead of being duplicated.

-- For example:
-- The employees table does not store branch_name or branch_city.

-- This prevents the following transitive dependency:

-- employee_id → branch_id → branch_name

-- Instead, branch_name is determined by branch_id
-- in the branches table.

-- Therefore, the database satisfies 3NF.



-- 5. TRANSITIVE DEPENDENCIES
-- ============================================================================

-- A transitive dependency occurs when:

-- A → B
-- B → C

-- which means:

-- A → C

-- In this system, branch information could create a transitive
-- dependency if it were stored inside the employees table.

-- For example:

-- employee_id → branch_id
-- branch_id → branch_name

-- Instead of storing branch_name in employees,
-- the system stores only:

-- branch_id

-- Branch information is retrieved through the relationship
-- with the branches table.

-- This reduces data duplication and prevents update anomalies.



-- 6. PROPOSED CHANGES
-- ============================================================================

-- The current database design is already largely normalized to 3NF.

-- The main normalization decisions are:
-- • Store customers separately from shipments.
-- • Store branches separately from employees, drivers, and vehicles.
-- • Store shipments separately from deliveries.
-- • Store payments separately from shipments.
-- • Store shipment movement history separately in shipment_tracking.
-- • Use foreign keys instead of duplicating complete entity information.
-- • Avoid storing calculated or repeated entity information unnecessarily.

-- No major structural changes are required to achieve 3NF.



-- 7. WHEN DENORMALIZATION CAN BE ACCEPTABLE
-- ============================================================================

-- Denormalization may be acceptable when performance becomes
-- more important than minimizing data duplication.

-- For example:
-- A frequently used reporting system might store a pre-calculated
-- summary such as customer_total_spending instead of calculating
-- it from all payment records every time.

-- However, denormalization should only be introduced when there is
-- a clear performance or reporting requirement.

-- The current system prioritizes data consistency and normalization,
-- while indexes, views, and optimized queries are used to improve
-- performance without unnecessary duplication.



-- ==============================================================================================
                    -- =================== Queries — 1 to 40 ================
-- =============================================================================================

    
-- Query 1
-- عرض جميع الشحنات مع اسم العميل وفرع الإرسال وفرع الاستلام
-- =====================================================

SELECT
    s.id,
    s.tracking_number,
    c.full_name AS customer_name,
    ob.branch_name AS origin_branch,
    db.branch_name AS destination_branch,
    s.shipping_cost,
    s.shipment_status
FROM shipments s
JOIN customers c
    ON s.customer_id = c.id
JOIN branches ob
    ON s.origin_branch_id = ob.id
JOIN branches db
    ON s.destination_branch_id = db.id;


-- =====================================================
-- Query 2
-- عرض الشحنات التي لم يتم تسليمها حتى الآن
-- =====================================================

SELECT
    id,
    tracking_number,
    customer_id,
    shipment_status,
    expected_delivery_date
FROM shipments
WHERE shipment_status <> 'delivered';


-- =====================================================
-- Query 3
-- عرض الشحنات التي تجاوزت expected_delivery_date ولم يتم تسليمها
-- =====================================================

SELECT
    id,
    tracking_number,
    expected_delivery_date,
    shipment_status
FROM shipments
WHERE expected_delivery_date < CURDATE()
  AND shipment_status <> 'delivered';


-- =====================================================
-- Query 4
-- عرض جميع الشحنات الخاصة بعميل محدد مرتبة من الأحدث إلى الأقدم
-- =====================================================

SELECT
    id,
    tracking_number,
    customer_id,
    shipping_cost,
    shipment_status,
    created_at
FROM shipments
WHERE customer_id = 1
ORDER BY created_at DESC;


-- =====================================================
-- Query 5
-- عرض عدد الشحنات لكل عميل، بما في ذلك العملاء الذين لم ينشئوا أي شحنة
-- =====================================================

SELECT
    c.id,
    c.full_name,
    COUNT(s.id) AS shipment_count
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
GROUP BY
    c.id,
    c.full_name;


-- =====================================================
-- Query 6
-- عرض إجمالي المبالغ التي دفعها كل عميل
-- =====================================================
SELECT
    c.id,
    c.full_name,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
   AND p.status = 'successful'
GROUP BY
    c.id,
    c.full_name;



-- =====================================================
-- Query 7
-- عرض العملاء الذين تجاوز مجموع قيمة شحناتهم 5000
-- =====================================================

SELECT
    c.id,
    c.full_name,
    SUM(s.shipping_cost) AS total_shipping_cost
FROM customers c
JOIN shipments s
    ON c.id = s.customer_id
GROUP BY
    c.id,
    c.full_name
HAVING SUM(s.shipping_cost) > 5000;


-- =====================================================
-- Query 8
-- عرض عدد الشحنات التي خرجت من كل فرع
-- =====================================================

SELECT
    b.id,
    b.branch_name,
    COUNT(s.id) AS outgoing_shipments
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.origin_branch_id
GROUP BY
    b.id,
    b.branch_name;


-- =====================================================
-- Query 9
-- عرض عدد الشحنات المستلمة في كل فرع
-- =====================================================

SELECT
    b.id,
    b.branch_name,
    COUNT(s.id) AS incoming_shipments
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.destination_branch_id
GROUP BY
    b.id,
    b.branch_name;


-- =====================================================
-- Query 10
-- عرض الفرع صاحب أكبر عدد من الشحنات المرسلة
-- =====================================================
SELECT
    b.id,
    b.branch_name,
    COUNT(s.id) AS outgoing_shipments
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.origin_branch_id
GROUP BY
    b.id,
    b.branch_name
ORDER BY outgoing_shipments DESC
LIMIT 1;


-- =====================================================
-- Query 11
-- عرض متوسط تكلفة الشحن لكل فرع
-- =====================================================

SELECT
    b.id,
    b.branch_name,
    AVG(s.shipping_cost) AS average_shipping_cost
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.origin_branch_id
GROUP BY
    b.id,
    b.branch_name;


-- =====================================================
-- Query 12
-- عرض أغلى شحنة في كل فرع
-- =====================================================
SELECT
    s.id,
    s.tracking_number,
    s.origin_branch_id,
    b.branch_name,
    s.shipping_cost
FROM shipments s
JOIN branches b
    ON s.origin_branch_id = b.id
WHERE s.shipping_cost = (
    SELECT MAX(s2.shipping_cost)
    FROM shipments s2
    WHERE s2.origin_branch_id = s.origin_branch_id
);


-- =====================================================
-- Query 13
-- عرض السائقين الذين قاموا بأكثر من 5 عمليات توصيل ناجحة
-- =====================================================

SELECT
    dr.id,
    dr.full_name,
    COUNT(d.id) AS successful_deliveries
FROM drivers dr
JOIN deliveries d
    ON dr.id = d.driver_id
WHERE d.delivery_status = 'completed'
GROUP BY
    dr.id,
    dr.full_name
HAVING COUNT(d.id) > 5;


-- =====================================================
-- Query 14
-- عرض عدد عمليات التوصيل لكل سائق، بما في ذلك السائقين
-- الذين لم ينفذوا أي عملية توصيل
-- =====================================================

SELECT
    dr.id,
    dr.full_name,
    COUNT(d.id) AS delivery_count
FROM drivers dr
LEFT JOIN deliveries d
    ON dr.id = d.driver_id
GROUP BY
    dr.id,
    dr.full_name;


-- =====================================================
-- Query 15
-- عرض السائق صاحب أكبر عدد من عمليات التوصيل المكتملة
-- =====================================================
SELECT
    d.id,
    d.full_name,
    COUNT(del.id) AS completed_deliveries
FROM drivers d
JOIN deliveries del
    ON d.id = del.driver_id
WHERE del.delivery_status = 'completed'
GROUP BY
    d.id,
    d.full_name
ORDER BY completed_deliveries DESC
LIMIT 1;


-- =====================================================
-- Query 16
-- عرض إجمالي قيمة الشحنات التي قام كل سائق بتوصيلها
-- =====================================================

SELECT
    dr.id,
    dr.full_name,
    SUM(s.shipping_cost) AS total_shipment_value
FROM drivers dr
JOIN deliveries d
    ON dr.id = d.driver_id
JOIN shipments s
    ON d.shipment_id = s.id
GROUP BY
    dr.id,
    dr.full_name;


-- =====================================================
-- Query 17
-- عرض المركبات التي لم تستخدم في أي عملية توصيل
-- =====================================================

SELECT
    v.id,
    v.plate_number,
    v.vehicle_type,
    v.status
FROM vehicles v
LEFT JOIN deliveries d
    ON v.id = d.vehicle_id
WHERE d.id IS NULL;


-- =====================================================
-- Query 18
-- عرض عدد مرات استخدام كل مركبة
-- =====================================================

SELECT
    v.id,
    v.plate_number,
    COUNT(d.id) AS usage_count
FROM vehicles v
LEFT JOIN deliveries d
    ON v.id = d.vehicle_id
GROUP BY
    v.id,
    v.plate_number;


-- =====================================================
-- Query 19
-- عرض المركبات التي استخدمت أكثر من متوسط استخدام جميع المركبات
-- =====================================================

SELECT
    v.id,
    v.plate_number,
    COUNT(d.id) AS usage_count
FROM vehicles v
LEFT JOIN deliveries d
    ON v.id = d.vehicle_id
GROUP BY
    v.id,
    v.plate_number
HAVING COUNT(d.id) > (
    SELECT AVG(vehicle_usage)
    FROM (
        SELECT
            v2.id,
            COUNT(d2.id) AS vehicle_usage
        FROM vehicles v2
        LEFT JOIN deliveries d2
            ON v2.id = d2.vehicle_id
        GROUP BY v2.id
    ) AS usage_table
);

-- =====================================================
-- Query 20
-- عرض الموظفين الذين رواتبهم أعلى من متوسط رواتب الموظفين
-- داخل نفس الفرع
-- =====================================================

SELECT
    e.id,
    e.full_name,
    e.branch_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.branch_id = e.branch_id
);


-- =====================================================
-- Query 21
-- عرض أعلى موظف راتبًا داخل كل فرع
-- =====================================================

SELECT
    e.id,
    e.full_name,
    e.branch_id,
    e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.branch_id = e.branch_id
);


-- =====================================================
-- Query 22
-- عرض ثاني أعلى راتب داخل كل فرع
-- =====================================================

SELECT
    id,
    full_name,
    branch_id,
    salary
FROM (
    SELECT
        e.id,
        e.full_name,
        e.branch_id,
        e.salary,
        DENSE_RANK() OVER (
            PARTITION BY e.branch_id
            ORDER BY e.salary DESC
        ) AS salary_rank
    FROM employees e
) AS ranked_employees
WHERE salary_rank = 2;


-- =====================================================
-- Query 23
-- عرض الفروع التي متوسط رواتب موظفيها أعلى من متوسط رواتب
-- جميع الموظفين في الشركة
-- =====================================================

SELECT
    b.id,
    b.branch_name,
    AVG(e.salary) AS branch_average_salary
FROM branches b
JOIN employees e
    ON b.id = e.branch_id
GROUP BY
    b.id,
    b.branch_name
HAVING AVG(e.salary) > (
    SELECT AVG(salary)
    FROM employees
);


-- =====================================================
-- Query 24
-- عرض العملاء الذين لديهم شحنة واحدة على الأقل ولكن لا توجد
-- لديهم أي شحنة تم تسليمها بنجاح
-- =====================================================

SELECT
    c.id,
    c.full_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM shipments s
    WHERE s.customer_id = c.id
)
AND NOT EXISTS (
    SELECT 1
    FROM shipments s2
    WHERE s2.customer_id = c.id
      AND s2.shipment_status = 'delivered'
);


-- =====================================================
-- Query 25
-- عرض العملاء الذين لديهم شحنات في أكثر من فرع إرسال مختلف
-- =====================================================

SELECT
    c.id,
    c.full_name,
    COUNT(DISTINCT s.origin_branch_id) AS origin_branch_count
FROM customers c
JOIN shipments s
    ON c.id = s.customer_id
GROUP BY
    c.id,
    c.full_name
HAVING COUNT(DISTINCT s.origin_branch_id) > 1;


-- =====================================================
-- Query 26
-- عرض العملاء الذين لم ينشئوا أي شحنة خلال آخر 90 يومًا
-- =====================================================

SELECT
    c.id,
    c.full_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM shipments s
    WHERE s.customer_id = c.id
      AND s.created_at >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
);


-- =====================================================
-- Query 27
-- عرض الشحنات التي لا يوجد لها أي سجل داخل shipment_tracking
-- =====================================================

SELECT
    s.id,
    s.tracking_number
FROM shipments s
LEFT JOIN shipment_tracking st
    ON s.id = st.shipment_id
WHERE st.id IS NULL;


-- =====================================================
-- Query 28
-- عرض آخر حالة Tracking مسجلة لكل شحنة
-- =====================================================

SELECT
    st.id,
    st.shipment_id,
    s.tracking_number,
    st.status,
    st.description,
    st.recorded_at
FROM shipment_tracking st
JOIN shipments s
    ON st.shipment_id = s.id
WHERE st.recorded_at = (
    SELECT MAX(st2.recorded_at)
    FROM shipment_tracking st2
    WHERE st2.shipment_id = st.shipment_id
);


-- =====================================================
-- Query 29
-- عرض التاريخ الكامل لحركة شحنة باستخدام tracking_number
-- =====================================================

SELECT
    s.tracking_number,
    st.status,
    st.description,
    st.recorded_at,
    b.branch_name
FROM shipments s
JOIN shipment_tracking st
    ON s.id = st.shipment_id
JOIN branches b
    ON st.branch_id = b.id
WHERE s.tracking_number = 'TRK100001'
ORDER BY st.recorded_at ASC;


-- =====================================================
-- Query 30
-- حساب المدة بين إنشاء الشحنة وتسليمها لكل شحنة مكتملة
-- =====================================================

SELECT
    id,
    tracking_number,
    created_at,
    delivered_at,
    DATEDIFF(delivered_at, created_at) AS delivery_days
FROM shipments
WHERE shipment_status = 'delivered'
  AND delivered_at IS NOT NULL;


-- =====================================================
-- Query 31
-- حساب متوسط مدة التوصيل بالأيام
-- =====================================================

SELECT
    AVG(DATEDIFF(delivered_at, created_at)) AS average_delivery_days
FROM shipments
WHERE shipment_status = 'delivered'
  AND delivered_at IS NOT NULL;


-- =====================================================
-- Query 32
-- عرض الشحنات التي مدة توصيلها أعلى من متوسط مدة التوصيل
-- =====================================================

SELECT
    id,
    tracking_number,
    DATEDIFF(delivered_at, created_at) AS delivery_days
FROM shipments
WHERE shipment_status = 'delivered'
  AND delivered_at IS NOT NULL
  AND DATEDIFF(delivered_at, created_at) > (
      SELECT AVG(DATEDIFF(delivered_at, created_at))
      FROM shipments
      WHERE shipment_status = 'delivered'
        AND delivered_at IS NOT NULL
  );


-- =====================================================
-- Query 33
-- عرض نسبة الشحنات التي تم تسليمها بنجاح من إجمالي الشحنات
-- =====================================================

SELECT
    (
        SELECT COUNT(*)
        FROM shipments
        WHERE shipment_status = 'delivered'
    ) * 100.0 / COUNT(*) AS delivered_percentage
FROM shipments;


-- =====================================================
-- Query 34
-- عرض نسبة الشحنات الملغاة لكل فرع
-- =====================================================

SELECT
    b.id,
    b.branch_name,
    COUNT(CASE
        WHEN s.shipment_status = 'cancelled' THEN 1
    END) * 100.0 / COUNT(s.id) AS cancelled_percentage
FROM branches b
LEFT JOIN shipments s
    ON b.id = s.origin_branch_id
GROUP BY
    b.id,
    b.branch_name;


-- =====================================================
-- Query 35
-- عرض الإيرادات الشهرية للسنة الحالية
-- =====================================================

SELECT
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE YEAR(payment_date) = YEAR(CURDATE())
  AND status = 'successful'
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date)
ORDER BY
    month;


-- =====================================================
-- Query 36
-- عرض الشهر صاحب أعلى إيرادات
-- =====================================================

SELECT
    MONTH(payment_date) AS month_number,
    MONTHNAME(payment_date) AS month_name,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE status = 'successful'
  AND YEAR(payment_date) = YEAR(CURDATE())
GROUP BY
    MONTH(payment_date),
    MONTHNAME(payment_date)
ORDER BY monthly_revenue DESC
LIMIT 1;

-- =====================================================
-- Query 37
-- عرض الإيرادات حسب طريقة الدفع
-- =====================================================

SELECT
    payment_method,
    SUM(amount) AS total_revenue
FROM payments
WHERE status = 'successful'
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- =====================================================
-- Query 38
-- عرض عمليات الدفع التي قيمتها مختلفة عن تكلفة الشحنة المرتبطة بها
-- =====================================================


SELECT
    p.id AS payment_id,
    p.shipment_id,
    p.amount AS payment_amount,
    s.shipping_cost,
    p.status
FROM payments p
JOIN shipments s
    ON p.shipment_id = s.id
WHERE p.status = 'successful'
  AND p.amount <> s.shipping_cost;
    


-- =====================================================
-- Query 39
-- عرض الشحنات التي حالتها paid ولكن لا يوجد لها سجل دفع ناجح
-- =====================================================

SELECT
    s.id,
    s.tracking_number,
    s.payment_status
FROM shipments s
WHERE s.payment_status = 'paid'
  AND NOT EXISTS (
      SELECT 1
      FROM payments p
      WHERE p.shipment_id = s.id
        AND p.status = 'successful'
  );


-- =====================================================
-- Query 40
-- عرض العملاء الذين مجموع إنفاقهم أعلى من متوسط إنفاق جميع العملاء
-- =====================================================
SELECT
    c.id,
    c.full_name,
    COALESCE(SUM(
        CASE
            WHEN p.status = 'successful' THEN p.amount
            ELSE 0
        END
    ), 0) AS total_spending
FROM customers c
LEFT JOIN shipments s
    ON c.id = s.customer_id
LEFT JOIN payments p
    ON s.id = p.shipment_id
GROUP BY
    c.id,
    c.full_name
HAVING total_spending > (
    SELECT AVG(customer_spending)
    FROM (
        SELECT
            c2.id,
            COALESCE(SUM(
                CASE
                    WHEN p2.status = 'successful' THEN p2.amount
                    ELSE 0
                END
            ), 0) AS customer_spending
        FROM customers c2
        LEFT JOIN shipments s2
            ON c2.id = s2.customer_id
        LEFT JOIN payments p2
            ON s2.id = p2.shipment_id
        GROUP BY c2.id
    ) AS spending_table
);






-- =================================================================================
--                         FINAL END-TO-END TEST
-- =================================================================================

-- The final end-to-end test validates the complete logistics workflow
-- from customer creation to successful shipment delivery.

-- Test Flow:

-- Customer
--     ↓
-- Shipment
--     ↓
-- Payment
--     ↓
-- Initial Tracking
--     ↓
-- Driver + Vehicle Assignment
--     ↓
-- Delivery Started
--     ↓
-- In-Transit Tracking
--     ↓
-- Delivery Completed
--     ↓
-- Final Delivered Tracking

-- =================================================================================


-- 1. CREATE CUSTOMER
-- ---------------------------------------------------------------------------------

-- A new customer was created specifically for the final system test.

-- The customer was successfully inserted into the customers table
-- with an active status.

-- =================================================================================


-- 2. CREATE SHIPMENT
-- ---------------------------------------------------------------------------------

-- A new shipment was created using the create_shipment stored procedure.

-- The procedure successfully:
-- - Created the shipment.
-- - Generated the shipment ID.
-- - Created the first tracking record.
-- - Set the initial shipment status to 'created'.

-- Test tracking number:
-- FINALTEST001

-- =================================================================================


-- 3. CREATE PAYMENT
-- ---------------------------------------------------------------------------------

-- A successful payment was created for the test shipment.

-- The payment was correctly linked to the shipment through shipment_id.

-- Payment status:
-- successful

-- The payment amount matched the shipment shipping cost.

-- =================================================================================


-- 4. INITIAL SHIPMENT TRACKING
-- ---------------------------------------------------------------------------------

-- The first tracking record was automatically created by the
-- create_shipment stored procedure with status 'created'.

-- This confirmed that every newly created shipment receives
-- an initial tracking record.

-- =================================================================================


-- 5. ASSIGN DRIVER AND VEHICLE
-- ---------------------------------------------------------------------------------

-- The shipment was assigned to:
-- - An active driver.
-- - An available vehicle.
-- - A vehicle with sufficient weight capacity.

-- The assign_delivery stored procedure successfully created
-- the delivery with status 'assigned'.

-- The vehicle status was changed to 'assigned'.

-- =================================================================================


-- 6. START DELIVERY
-- ---------------------------------------------------------------------------------

-- The delivery status was changed from 'assigned' to 'in_progress'.

-- The corresponding trigger automatically changed the vehicle status
-- from 'assigned' to 'in_delivery'.


-- =================================================================================


-- 7. ADD IN-TRANSIT TRACKING
-- ---------------------------------------------------------------------------------

-- A new tracking record was inserted with status 'in_transit'.

-- The tracking trigger automatically updated the shipment status
-- to 'in_transit'.

-- This confirmed that the shipment status remains synchronized
-- with shipment movement history.

-- =================================================================================


-- 8. COMPLETE DELIVERY
-- ---------------------------------------------------------------------------------

-- The complete_delivery stored procedure was executed successfully.

-- The procedure completed the delivery transaction and:
-- - Set the delivery status to 'completed'.
-- - Updated the shipment status to 'delivered'.
-- - Set delivered_at.
-- - Added a final 'delivered' tracking record.
-- - Returned the vehicle to 'available'.
-- - Used transaction handling to protect the operation from partial updates.

-- =================================================================================


-- 9. FINAL TRACKING HISTORY
-- ---------------------------------------------------------------------------------

-- The final tracking history contained the expected movement sequence:

-- created
-- in_transit
-- delivered

-- This confirms that the system preserves the complete shipment
-- movement history.

-- =================================================================================


-- 10. FINAL VERIFICATION
-- ---------------------------------------------------------------------------------

-- The final state was verified across the related tables.

-- Shipment:
-- shipment_status = delivered
-- delivered_at IS NOT NULL
-- payment_status = paid

-- Payment:
-- status = successful

-- Delivery:
-- delivery_status = completed
-- completed_at IS NOT NULL

-- Vehicle:
-- status = available

-- Tracking:
-- created → in_transit → delivered

-- The relationships between customer, shipment, payment, delivery,
-- driver, vehicle, and tracking records were verified successfully.

-- No orphan records were introduced during the final test.

-- =================================================================================


-- FINAL RESULT
-- =================================================================================

-- The Logistics & Delivery Management System successfully completed
-- the complete end-to-end workflow:

-- Customer
-- → Shipment
-- → Payment
-- → Tracking
-- → Driver Assignment
-- → Vehicle Assignment
-- → Delivery Start
-- → In Transit
-- → Delivery Completion
-- → Final Tracking

-- The final shipment state, payment, delivery, vehicle status,
-- and tracking history were all verified successfully.

-- =================================================================================



-- ================================================================================
  --                       DATABASE 3
-- ================================================================================



CREATE DATABASE IF NOT EXISTS marketplace_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE marketplace_system;




CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status ENUM('active', 'inactive', 'blocked')
        NOT NULL DEFAULT 'active'
);





CREATE TABLE customer_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    street VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,

        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    UNIQUE KEY uq_customer_address (customer_id, id)
);




CREATE TABLE sellers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(150) NOT NULL,
    owner_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    commission_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status ENUM('pending', 'active', 'suspended', 'closed')
        NOT NULL DEFAULT 'pending',
        CHECK (commission_rate >= 0 AND commission_rate <= 100)
);







CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NULL,
    category_name VARCHAR(150) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'active',

        FOREIGN KEY (parent_id)
        REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    UNIQUE KEY uq_category_name_parent (parent_id, category_name)
);



CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(12,2) NOT NULL,
    cost_price DECIMAL(12,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    minimum_stock INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status ENUM(
        'active',
        'inactive',
        'out_of_stock',
        'discontinued'
    ) NOT NULL DEFAULT 'active',


        FOREIGN KEY (seller_id)
        REFERENCES sellers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        CHECK (price >= 0),
        CHECK (cost_price >= 0)
);




CREATE TABLE product_price_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(12,2) NOT NULL,
    new_price DECIMAL(12,2) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        CHECK (old_price >= 0),
        CHECK (new_price >= 0)
);




CREATE TABLE carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'converted', 'abandoned')
        NOT NULL DEFAULT 'active',
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);




CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY (cart_id)
        REFERENCES carts(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        CHECK (quantity > 0),
    UNIQUE KEY uq_cart_product (cart_id, product_id)
);





CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    minimum_order DECIMAL(12,2) NOT NULL DEFAULT 0,
    maximum_discount DECIMAL(12,2) NULL,
    usage_limit INT NOT NULL,
    used_count INT NOT NULL DEFAULT 0,
    starts_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'active',
    
        CHECK (discount_value >= 0),
        CHECK (minimum_order >= 0),
        CHECK (used_count <= usage_limit),
        CHECK (expires_at > starts_at)
);



CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(100) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    coupon_id INT,

    subtotal DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,

    ordered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status ENUM(
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
        'partially_returned',
        'returned'
    ) NOT NULL DEFAULT 'pending',

        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        FOREIGN KEY (customer_id, address_id)
        REFERENCES customer_addresses(customer_id, id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        FOREIGN KEY (coupon_id)
        REFERENCES coupons(id)
    
);





CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    seller_id INT NOT NULL,

    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    platform_commission DECIMAL(12,2) NOT NULL DEFAULT 0,
    seller_amount DECIMAL(12,2) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'active',

   
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

   
        FOREIGN KEY (seller_id)
        REFERENCES sellers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    
        CHECK (quantity > 0),
        CHECK (unit_price >= 0),
        CHECK (discount_amount >= 0),
        CHECK (platform_commission >= 0),
        CHECK (seller_amount >= 0)
);




CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_reference VARCHAR(150) NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,

    payment_method ENUM(
        'pix',
        'card',
        'bank_transfer',
        'wallet'
    ) NOT NULL,

    paid_at DATETIME,

    status ENUM(
        'pending',
        'paid',
        'failed',
        'refunded',
        'partially_refunded'
    ) NOT NULL DEFAULT 'pending',

        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
  
        CHECK (amount >= 0)
);






CREATE TABLE shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    tracking_number VARCHAR(150) NOT NULL UNIQUE,
    shipping_company VARCHAR(150) NOT NULL,
    shipped_at DATETIME NULL,
    expected_delivery DATETIME NULL,
    delivered_at DATETIME NULL,
    status ENUM( 
     'pending',
    'shipped',
    'in_transit',
    'delivered',
    'cancelled') NOT NULL,

        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);








CREATE TABLE returns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    quantity INT NOT NULL,
    reason VARCHAR(500) NOT NULL,

    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME NULL,
    completed_at DATETIME NULL,

    status ENUM(
        'requested',
        'approved',
        'rejected',
        'completed'
    ) NOT NULL DEFAULT 'requested',


        FOREIGN KEY (order_item_id)
        REFERENCES order_items(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        CHECK (quantity > 0)
);






CREATE TABLE refunds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    return_id INT NOT NULL,
    payment_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    refunded_at DATETIME NULL,
    status VARCHAR(50) NOT NULL,


        FOREIGN KEY (return_id)
        REFERENCES returns(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        FOREIGN KEY (payment_id)
        REFERENCES payments(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
 
        CHECK (amount >= 0)
);




CREATE TABLE reviews (
    id INT
    AUTO_INCREMENT PRIMARY KEY,   
    customer_id INT NOT NULL,
   
    product_id INT NOT NULL,

    order_item_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
  
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        FOREIGN KEY (order_item_id)
        REFERENCES order_items(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
   
        CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY uq_customer_order_item_review
        (customer_id, order_item_id)
);






CREATE TABLE seller_settlements (
    id INT
    AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    gross_sales DECIMAL(12,2) NOT NULL DEFAULT 0,
    commission_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    refund_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    net_amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    paid_at DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',

        FOREIGN KEY (seller_id)
        REFERENCES sellers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

        CHECK (gross_sales >= 0),

        CHECK (commission_amount >= 0),
 
        CHECK (refund_amount >= 0),

        CHECK (net_amount >= 0),

        CHECK (period_end >= period_start),
    UNIQUE KEY uq_seller_settlement_period
        (seller_id, period_start, period_end)
);

















-- Corrected complete seed data. Run only on empty tables with AUTO_INCREMENT starting at 1.
-- Tables and INSERT column lists match the supplied file.

INSERT INTO customers
(full_name, email, phone, status)
VALUES
('Ahmed Taha', 'ahmed.taha01@gmail.com', '+902840571001', 'active'),
('Sara Ali', 'sara.ali02@gmail.com', '+902840571002', 'active'),
('Omar Hassan', 'omar.hassan03@gmail.com', '+902840571003', 'inactive'),
('Lina Khaled', 'lina.khaled04@gmail.com', '+902840571004', 'active'),
('Youssef Mahmoud', 'youssef.mahmoud05@gmail.com', '+902840571005', 'blocked'),
('Mariam Saleh', 'mariam.saleh06@gmail.com', '+902840571006', 'active'),
('Adam Ibrahim', 'adam.ibrahim07@gmail.com', '+902840571007', 'active'),
('Nour Ahmed', 'nour.ahmed08@gmail.com', '+902840571008', 'inactive'),
('Karim Adel', 'karim.adel09@gmail.com', '+902840571009', 'active'),
('Hana Mostafa', 'hana.mostafa10@gmail.com', '+902840571010', 'active'),
('Ali Nasser', 'ali.nasser11@gmail.com', '+902840571011', 'active'),
('Layla Sami', 'layla.sami12@gmail.com', '+902840571012', 'blocked'),
('Khaled Amin', 'khaled.amin13@gmail.com', '+902840571013', 'active'),
('Rana Fadi', 'rana.fadi14@gmail.com', '+902840571014', 'inactive'),
('Tarek Samir', 'tarek.samir15@gmail.com', '+902840571015', 'active'),
('Dina Hossam', 'dina.hossam16@gmail.com', '+902840571016', 'active'),
('Mahmoud Yasin', 'mahmoud.yasin17@gmail.com', '+902840571017', 'active'),
('Reem Adel', 'reem.adel18@gmail.com', '+902840571018', 'inactive'),
('Ziad Karim', 'ziad.karim19@gmail.com', '+902840571019', 'active'),
('Salma Nabil', 'salma.nabil20@gmail.com', '+902840571020', 'blocked'),
('Hasan Omar', 'hasan.omar21@gmail.com', '+902840571021', 'active'),
('Maya Khalil', 'maya.khalil22@gmail.com', '+902840571022', 'active'),
('Faris Ahmed', 'faris.ahmed23@gmail.com', '+902840571023', 'inactive'),
('Jana Ali', 'jana.ali24@gmail.com', '+902840571024', 'active'),
('Sami Hassan', 'sami.hassan25@gmail.com', '+902840571025', 'active'),
('Nada Mahmoud', 'nada.mahmoud26@gmail.com', '+902840571026', 'active'),
('Bilal Saleh', 'bilal.saleh27@gmail.com', '+902840571027', 'blocked'),
('Huda Ibrahim', 'huda.ibrahim28@gmail.com', '+902840571028', 'active'),
('Rami Nasser', 'rami.nasser29@gmail.com', '+902840571029', 'inactive'),
('Amira Khaled', 'amira.khaled30@gmail.com', '+902840571030', 'active'),
('Ibrahim Sami', 'ibrahim.sami31@gmail.com', '+902840571031', 'active'),
('Dalia Omar', 'dalia.omar32@gmail.com', '+902840571032', 'active'),
('Mustafa Adel', 'mustafa.adel33@gmail.com', '+902840571033', 'inactive'),
('Rita Nabil', 'rita.nabil34@gmail.com', '+902840571034', 'active'),
('Walid Fadi', 'walid.fadi35@gmail.com', '+902840571035', 'blocked'),
('Aya Samir', 'aya.samir36@gmail.com', '+902840571036', 'active'),
('Saeed Yasin', 'saeed.yasin37@gmail.com', '+902840571037', 'active'),
('Lama Karim', 'lama.karim38@gmail.com', '+902840571038', 'inactive'),
('Fadi Hossam', 'fadi.hossam39@gmail.com', '+902840571039', 'active'),
('Rania Amin', 'rania.amin40@gmail.com', '+902840571040', 'active'),
('Nader Hassan', 'nader.hassan41@gmail.com', '+902840571041', 'active'),
('Mona Saleh', 'mona.saleh42@gmail.com', '+902840571042', 'inactive'),
('Yara Ahmed', 'yara.ahmed43@gmail.com', '+902840571043', 'active'),
('Sultan Ali', 'sultan.ali44@gmail.com', '+902840571044', 'blocked'),
('Farah Mahmoud', 'farah.mahmoud45@gmail.com', '+902840571045', 'active'),
('Ayman Khaled', 'ayman.khaled46@gmail.com', '+902840571046', 'active'),
('Layan Sami', 'layan.sami47@gmail.com', '+902840571047', 'inactive'),
('Hani Ibrahim', 'hani.ibrahim48@gmail.com', '+902840571048', 'active'),
('Sahar Nasser', 'sahar.nasser49@gmail.com', '+902840571049', 'active'),
('Majed Adel', 'majed.adel50@gmail.com', '+902840571050', 'blocked'),
('Rasha Karim', 'rasha.karim51@gmail.com', '+902840571051', 'active'),
('Fahad Omar', 'fahad.omar52@gmail.com', '+902840571052', 'active'),
('Dima Hassan', 'dima.hassan53@gmail.com', '+902840571053', 'inactive'),
('Bassem Saleh', 'bassem.saleh54@gmail.com', '+902840571054', 'active'),
('Laila Fadi', 'laila.fadi55@gmail.com', '+902840571055', 'active'),
('Anas Samir', 'anas.samir56@gmail.com', '+902840571056', 'active'),
('Hiba Yasin', 'hiba.yasin57@gmail.com', '+902840571057', 'blocked'),
('Tamer Nabil', 'tamer.nabil58@gmail.com', '+902840571058', 'inactive'),
('Samar Ahmed', 'samar.ahmed59@gmail.com', '+902840571059', 'active'),
('Bassam Ali', 'bassam.ali60@gmail.com', '+902840571060', 'active'),
('Rayan Khaled', 'rayan.khaled61@gmail.com', '+902840571061', 'active'),
('Mira Hassan', 'mira.hassan62@gmail.com', '+902840571062', 'inactive'),
('Wassim Mahmoud', 'wassim.mahmoud63@gmail.com', '+902840571063', 'active'),
('Sonia Saleh', 'sonia.saleh64@gmail.com', '+902840571064', 'active'),
('Nabil Ibrahim', 'nabil.ibrahim65@gmail.com', '+902840571065', 'blocked'),
('Joud Ali', 'joud.ali66@gmail.com', '+902840571066', 'active'),
('Hussein Sami', 'hussein.sami67@gmail.com', '+902840571067', 'active'),
('Mariam Nasser', 'mariam.nasser68@gmail.com', '+902840571068', 'inactive'),
('Kareem Fadi', 'kareem.fadi69@gmail.com', '+902840571069', 'active'),
('Salim Yasin', 'salim.yasin70@gmail.com', '+902840571070', 'active');

INSERT INTO customer_addresses
(customer_id, title, city, district, street, postal_code, is_default)
VALUES
(1, 'Home', 'Istanbul', 'Kadikoy', 'Bagdat Caddesi No:15', '34710', 1),
(2, 'Apartment', 'Istanbul', 'Besiktas', 'Ihlamurdere Caddesi No:28', '34349', 1),
(3, 'Residence', 'Istanbul', 'Sisli', 'Halaskargazi Caddesi No:42', '34371', 1),
(4, 'Home', 'Ankara', 'Cankaya', 'Tunali Hilmi Caddesi No:18', '06680', 1),
(5, 'Family House', 'Izmir', 'Konak', 'Mithatpasa Caddesi No:55', '35260', 1),
(6, 'Apartment', 'Istanbul', 'Uskudar', 'Selmanipak Caddesi No:12', '34668', 1),
(7, 'Home', 'Bursa', 'Nilufer', 'Gorukle Caddesi No:31', '16285', 1),
(8, 'Residence', 'Antalya', 'Muratpasa', 'Lara Caddesi No:24', '07100', 1),
(9, 'Family House', 'Adana', 'Seyhan', 'Ziyapasa Bulvari No:17', '01140', 1),
(10, 'Apartment', 'Istanbul', 'Maltepe', 'Baglarbasi Caddesi No:9', '34844', 1),
(11, 'Home', 'Ankara', 'Kecioren', 'Etlik Caddesi No:36', '06290', 1),
(12, 'Residence', 'Izmir', 'Bornova', 'Kazim Dirik Caddesi No:44', '35100', 1),
(13, 'Apartment', 'Istanbul', 'Bakirkoy', 'Istasyon Caddesi No:21', '34142', 1),
(14, 'Family House', 'Bursa', 'Osmangazi', 'Cekirge Caddesi No:13', '16100', 1),
(15, 'Home', 'Antalya', 'Konyaalti', 'Arapsuyu Caddesi No:48', '07070', 1),
(16, 'Residence', 'Istanbul', 'Fatih', 'Fevzi Pasa Caddesi No:27', '34083', 1),
(17, 'Apartment', 'Ankara', 'Etimesgut', 'Baglica Bulvari No:19', '06790', 1),
(18, 'Home', 'Istanbul', 'Kartal', 'Kordonboyu Caddesi No:33', '34860', 1),
(19, 'Family House', 'Izmir', 'Karsiyaka', 'Cemal Gurbuz Caddesi No:11', '35540', 1),
(20, 'Residence', 'Adana', 'Cukurova', 'Turgut Ozal Bulvari No:29', '01170', 1),
(21, 'Apartment', 'Istanbul', 'Atasehir', 'Kayisdagi Caddesi No:16', '34750', 1),
(22, 'Home', 'Istanbul', 'Umraniye', 'Alemdag Caddesi No:51', '34768', 1),
(23, 'Family House', 'Ankara', 'Mamak', 'Dikimevi Caddesi No:25', '06620', 1),
(24, 'Residence', 'Izmir', 'Buca', 'Menderes Caddesi No:37', '35370', 1),
(25, 'Apartment', 'Bursa', 'Yildirim', 'Davutdede Caddesi No:62', '16350', 1),
(26, 'Home', 'Istanbul', 'Pendik', 'Gazi Pasa Caddesi No:14', '34890', 1),
(27, 'Residence', 'Antalya', 'Kepez', 'Sakarya Bulvari No:23', '07060', 1),
(28, 'Family House', 'Istanbul', 'Bakirkoy', 'Yesilkoy Caddesi No:39', '34149', 1),
(29, 'Apartment', 'Ankara', 'Cankaya', 'Mesrutiyet Caddesi No:8', '06420', 1),
(30, 'Home', 'Izmir', 'Konak', 'Kibris Sehitleri Caddesi No:46', '35220', 1),
(31, 'Residence', 'Istanbul', 'Kadikoy', 'Moda Caddesi No:32', '34710', 1),
(32, 'Apartment', 'Istanbul', 'Beyoglu', 'Siraselviler Caddesi No:74', '34433', 1),
(33, 'Family House', 'Bursa', 'Nilufer', 'Odunluk Caddesi No:18', '16110', 1),
(34, 'Home', 'Antalya', 'Muratpasa', 'Guzeloba Caddesi No:27', '07230', 1),
(35, 'Residence', 'Adana', 'Seyhan', 'Cemalpasa Caddesi No:41', '01120', 1),
(36, 'Apartment', 'Istanbul', 'Sariyer', 'Buyukdere Caddesi No:63', '34453', 1),
(37, 'Home', 'Ankara', 'Yenimahalle', 'Ivedik Caddesi No:22', '06378', 1),
(38, 'Family House', 'Izmir', 'Bayrakli', 'Mansuroglu Caddesi No:35', '35535', 1),
(39, 'Residence', 'Istanbul', 'Esenyurt', 'Dogan Arasli Bulvari No:17', '34510', 1),
(40, 'Apartment', 'Bursa', 'Osmangazi', 'Altinova Caddesi No:45', '16250', 1),
(41, 'Home', 'Istanbul', 'Uskudar', 'Kisikli Caddesi No:29', '34676', 1),
(42, 'Residence', 'Ankara', 'Cankaya', 'Esat Caddesi No:52', '06660', 1),
(43, 'Apartment', 'Izmir', 'Bornova', 'Ergene Caddesi No:16', '35040', 1),
(44, 'Family House', 'Antalya', 'Konyaalti', 'Liman Caddesi No:38', '07130', 1),
(45, 'Home', 'Istanbul', 'Sisli', 'Valikonagi Caddesi No:21', '34365', 1),
(46, 'Residence', 'Adana', 'Seyhan', 'Kurtulus Caddesi No:34', '01130', 1),
(47, 'Apartment', 'Istanbul', 'Avcilar', 'Marmara Caddesi No:12', '34320', 1),
(48, 'Home', 'Bursa', 'Nilufer', 'Fethiye Caddesi No:47', '16140', 1),
(49, 'Family House', 'Ankara', 'Altindag', 'Talatpasa Bulvari No:26', '06140', 1),
(50, 'Residence', 'Izmir', 'Gaziemir', 'Akcay Caddesi No:53', '35410', 1),
(51, 'Apartment', 'Istanbul', 'Bakirkoy', 'Atakoy Caddesi No:18', '34158', 1),
(52, 'Home', 'Istanbul', 'Besiktas', 'Nispetiye Caddesi No:105', '34340', 1),
(53, 'Residence', 'Ankara', 'Kecioren', 'Sanatoryum Caddesi No:33', '06280', 1),
(54, 'Family House', 'Izmir', 'Karsiyaka', 'Girne Bulvari No:24', '35560', 1),
(55, 'Apartment', 'Antalya', 'Muratpasa', 'Fener Caddesi No:61', '07160', 1),
(56, 'Home', 'Istanbul', 'Kartal', 'Soganlik Caddesi No:14', '34880', 1),
(57, 'Residence', 'Bursa', 'Yildirim', 'Setbasi Caddesi No:28', '16360', 1),
(58, 'Apartment', 'Adana', 'Cukurova', 'Toros Caddesi No:39', '01170', 1),
(59, 'Family House', 'Istanbul', 'Pendik', 'Kaynarca Caddesi No:25', '34890', 1),
(60, 'Home', 'Ankara', 'Etimesgut', 'Eryaman Caddesi No:44', '06820', 1),
(61, 'Residence', 'Istanbul', 'Kadikoy', 'Fenerbahce Caddesi No:17', '34726', 1),
(62, 'Apartment', 'Izmir', 'Konak', 'Cumhuriyet Bulvari No:36', '35220', 1),
(63, 'Home', 'Antalya', 'Kepez', 'Dumlupinar Bulvari No:49', '07090', 1),
(64, 'Family House', 'Istanbul', 'Umraniye', 'Ihlamurkuyu Caddesi No:22', '34771', 1),
(65, 'Residence', 'Bursa', 'Osmangazi', 'Kukurtlu Caddesi No:31', '16080', 1),
(66, 'Apartment', 'Ankara', 'Cankaya', 'Oran Caddesi No:15', '06450', 1),
(67, 'Home', 'Istanbul', 'Beylikduzu', 'Adnan Kahveci Bulvari No:27', '34528', 1),
(68, 'Residence', 'Adana', 'Seyhan', 'Resatbey Caddesi No:42', '01120', 1),
(69, 'Family House', 'Izmir', 'Bornova', 'Evka Caddesi No:19', '35050', 1),
(70, 'Apartment', 'Istanbul', 'Sancaktepe', 'Sarikazi Caddesi No:34', '34885', 1);

INSERT INTO sellers
(store_name, owner_name, email, phone, commission_rate, status)
VALUES
('Tech World', 'Ahmed Taha', 'techworld01@gmail.com', '+902840580001', 8.5, 'active'),
('Fashion House', 'Sara Ali', 'fashionhouse02@gmail.com', '+902840580002', 10.0, 'active'),
('Home Center', 'Omar Hassan', 'homecenter03@gmail.com', '+902840580003', 7.5, 'pending'),
('Smart Market', 'Lina Khaled', 'smartmarket04@gmail.com', '+902840580004', 12.0, 'active'),
('Book Planet', 'Youssef Mahmoud', 'bookplanet05@gmail.com', '+902840580005', 6.0, 'suspended'),
('Beauty Store', 'Mariam Saleh', 'beautystore06@gmail.com', '+902840580006', 9.5, 'active'),
('Sports Zone', 'Adam Ibrahim', 'sportszone07@gmail.com', '+902840580007', 11.0, 'active'),
('Kids World', 'Nour Ahmed', 'kidsworld08@gmail.com', '+902840580008', 8.0, 'pending'),
('Electro Shop', 'Karim Adel', 'electroshop09@gmail.com', '+902840580009', 13.5, 'active'),
('Garden Life', 'Hana Mostafa', 'gardenlife10@gmail.com', '+902840580010', 5.5, 'closed'),
('Mobile Center', 'Ali Nasser', 'mobilecenter11@gmail.com', '+902840580011', 14.0, 'active'),
('Luxury Store', 'Layla Sami', 'luxurystore12@gmail.com', '+902840580012', 15.0, 'suspended'),
('Daily Market', 'Khaled Amin', 'dailymarket13@gmail.com', '+902840580013', 7.0, 'active'),
('Office Plus', 'Rana Fadi', 'officeplus14@gmail.com', '+902840580014', 6.5, 'pending'),
('Auto Parts', 'Tarek Samir', 'autoparts15@gmail.com', '+902840580015', 9.0, 'active'),
('Pet World', 'Dina Hossam', 'petworld16@gmail.com', '+902840580016', 8.75, 'active'),
('Music Store', 'Mahmoud Yasin', 'musicstore17@gmail.com', '+902840580017', 10.5, 'suspended'),
('Coffee Market', 'Reem Adel', 'coffeemarket18@gmail.com', '+902840580018', 5.0, 'active'),
('Travel Shop', 'Ziad Karim', 'travelshop19@gmail.com', '+902840580019', 12.5, 'pending'),
('Gift Center', 'Salma Nabil', 'giftcenter20@gmail.com', '+902840580020', 7.25, 'active');

INSERT INTO categories
(parent_id, category_name, status)
VALUES
(NULL, 'Electronics', 'active'),
(NULL, 'Clothing', 'active'),
(NULL, 'Home & Kitchen', 'active'),
(NULL, 'Beauty & Personal Care', 'active'),
(NULL, 'Sports', 'active'),
(1, 'Mobile Phones', 'active'),
(1, 'Laptops', 'active'),
(1, 'Headphones', 'active'),
(2, 'Men Clothing', 'active'),
(2, 'Women Clothing', 'active'),
(2, 'Shoes', 'active'),
(3, 'Kitchen Appliances', 'active'),
(3, 'Furniture', 'active'),
(4, 'Skin Care', 'active'),
(5, 'Fitness Equipment', 'active');

INSERT INTO products
(seller_id, category_id, sku, product_name, description, price, cost_price, stock_quantity, minimum_stock, status)
VALUES
(1, 1, 'SKU-ELC-001', 'Samsung Galaxy A15', 'Akilli telefon', 8999.9, 7200.0, 35, 5, 'active'),
(2, 1, 'SKU-ELC-002', 'Apple iPhone 15', 'Apple akilli telefon', 42999.9, 36500.0, 20, 5, 'active'),
(3, 1, 'SKU-ELC-003', 'Xiaomi Redmi Note 13', 'Xiaomi akilli telefon', 10999.9, 8500.0, 42, 8, 'active'),
(4, 1, 'SKU-ELC-004', 'Huawei Nova 11', 'Huawei akilli telefon', 14999.9, 11800.0, 18, 4, 'active'),
(5, 1, 'SKU-ELC-005', 'Oppo Reno 11', 'Oppo akilli telefon', 16999.9, 13200.0, 25, 5, 'active'),
(6, 1, 'SKU-ELC-006', 'Samsung Galaxy S24', 'Samsung amiral gemisi telefon', 34999.9, 28500.0, 12, 3, 'active'),
(7, 1, 'SKU-ELC-007', 'Google Pixel 8', 'Google akilli telefon', 27999.9, 22500.0, 15, 3, 'active'),
(8, 1, 'SKU-ELC-008', 'OnePlus Nord 3', 'OnePlus akilli telefon', 18999.9, 14800.0, 22, 4, 'active'),
(9, 2, 'SKU-FSH-009', 'Erkek Basic Tisort', 'Pamuklu erkek tisortu', 499.9, 250.0, 80, 15, 'active'),
(10, 2, 'SKU-FSH-010', 'Kadin Basic Tisort', 'Pamuklu kadin tisortu', 499.9, 250.0, 75, 15, 'active'),
(11, 2, 'SKU-FSH-011', 'Erkek Kot Pantolon', 'Klasik kot pantolon', 1299.9, 700.0, 45, 8, 'active'),
(12, 2, 'SKU-FSH-012', 'Kadin Kot Pantolon', 'Modern kot pantolon', 1399.9, 760.0, 40, 8, 'active'),
(13, 2, 'SKU-FSH-013', 'Erkek Spor Mont', 'Su gecirmez spor mont', 2499.9, 1450.0, 30, 6, 'active'),
(14, 2, 'SKU-FSH-014', 'Kadin Kaban', 'Kislik kadin kaban', 2999.9, 1750.0, 25, 5, 'active'),
(15, 2, 'SKU-FSH-015', 'Erkek Sweatshirt', 'Kapusonlu sweatshirt', 999.9, 520.0, 60, 10, 'active'),
(16, 2, 'SKU-FSH-016', 'Kadin Sweatshirt', 'Gunluk sweatshirt', 999.9, 520.0, 55, 10, 'active'),
(17, 3, 'SKU-HOM-017', 'Modern Koltuk', 'Uc kisilik modern koltuk', 8999.9, 6100.0, 10, 2, 'active'),
(18, 3, 'SKU-HOM-018', 'Ahşap Yemek Masasi', 'Ahşap yemek masasi', 6499.9, 4300.0, 8, 2, 'active'),
(19, 3, 'SKU-HOM-019', 'Ofis Calisma Masasi', 'Modern calisma masasi', 3499.9, 2200.0, 15, 3, 'active'),
(20, 3, 'SKU-HOM-020', 'Kitaplik', 'Bes rafli kitaplik', 1999.9, 1150.0, 25, 5, 'active'),
(1, 3, 'SKU-HOM-021', 'TV Unitesi', 'Modern TV unitesi', 3999.9, 2500.0, 12, 3, 'active'),
(2, 3, 'SKU-HOM-022', 'Komodin', 'Ahşap komodin', 1499.9, 850.0, 20, 4, 'active'),
(3, 3, 'SKU-HOM-023', 'Gardrop', 'Uclu kapakli gardrop', 5999.9, 3800.0, 9, 2, 'active'),
(4, 3, 'SKU-HOM-024', 'Calisma Sandalyesi', 'Ergonomik ofis sandalyesi', 2799.9, 1700.0, 18, 4, 'active'),
(5, 4, 'SKU-SPT-025', 'Yoga Matisi', 'Kaymaz yoga matı', 699.9, 350.0, 70, 10, 'active'),
(6, 4, 'SKU-SPT-026', 'Dambıl Seti', '20 kg dambıl seti', 1599.9, 950.0, 35, 7, 'active'),
(7, 4, 'SKU-SPT-027', 'Koşu Ayakkabisi', 'Profesyonel kosu ayakkabisi', 2499.9, 1500.0, 28, 5, 'active'),
(8, 4, 'SKU-SPT-028', 'Futbol Topu', 'Profesyonel futbol topu', 899.9, 450.0, 50, 10, 'active'),
(9, 4, 'SKU-SPT-029', 'Basketbol Topu', 'Salon basketbol topu', 999.9, 500.0, 45, 8, 'active'),
(10, 4, 'SKU-SPT-030', 'Fitness Eldiveni', 'Spor salonu eldiveni', 399.9, 180.0, 90, 15, 'active'),
(11, 4, 'SKU-SPT-031', 'Spor Cantasi', 'Buyuk spor cantasi', 799.9, 400.0, 40, 8, 'active'),
(12, 4, 'SKU-SPT-032', 'Bisiklet Kaski', 'Guvenli bisiklet kaski', 1199.9, 650.0, 32, 6, 'active'),
(13, 5, 'SKU-BOK-033', 'SQL Ogreniyorum', 'SQL egitim kitabi', 349.9, 180.0, 60, 10, 'active'),
(14, 5, 'SKU-BOK-034', 'Python Programlama', 'Python baslangic kitabi', 449.9, 230.0, 55, 10, 'active'),
(15, 5, 'SKU-BOK-035', 'Web Gelistirme', 'Web programlama kitabi', 499.9, 260.0, 45, 8, 'active'),
(16, 5, 'SKU-BOK-036', 'Veri Yapilari', 'Veri yapilari ders kitabi', 399.9, 210.0, 35, 7, 'active'),
(17, 5, 'SKU-BOK-037', 'Algoritmalar', 'Algoritma ve programlama kitabi', 549.9, 290.0, 30, 6, 'active'),
(18, 5, 'SKU-BOK-038', 'Java Programlama', 'Java egitim kitabi', 599.9, 320.0, 25, 5, 'active'),
(19, 5, 'SKU-BOK-039', 'Veritabani Sistemleri', 'Veritabani yonetim kitabi', 479.9, 250.0, 40, 8, 'active'),
(20, 5, 'SKU-BOK-040', 'Yapay Zeka Temelleri', 'Yapay zeka baslangic kitabi', 649.9, 350.0, 22, 4, 'active'),
(1, 6, 'SKU-ACC-041', 'USB-C Sarj Kablosu', 'Hizli sarj destekli kablo', 249.9, 100.0, 120, 20, 'active'),
(2, 6, 'SKU-ACC-042', 'Bluetooth Kulaklik', 'Kablosuz bluetooth kulaklik', 1299.9, 700.0, 65, 12, 'active'),
(3, 6, 'SKU-ACC-043', 'Telefon Kilifi', 'Silikon telefon kilifi', 199.9, 70.0, 150, 25, 'active'),
(4, 6, 'SKU-ACC-044', 'Ekran Koruyucu', 'Temperli cam ekran koruyucu', 149.9, 50.0, 180, 30, 'active'),
(5, 6, 'SKU-ACC-045', 'Powerbank 20000mAh', 'Yuksek kapasiteli powerbank', 999.9, 550.0, 40, 8, 'active'),
(6, 6, 'SKU-ACC-046', 'Kablosuz Sarj Standi', 'Telefon sarj standi', 799.9, 420.0, 35, 7, 'active'),
(7, 6, 'SKU-ACC-047', 'USB Hub', 'Coklu USB hub', 599.9, 300.0, 50, 10, 'active'),
(8, 6, 'SKU-ACC-048', 'Laptop Cantasi', '15.6 inc laptop cantasi', 899.9, 480.0, 28, 5, 'active'),
(9, 7, 'SKU-LAP-049', 'Lenovo IdeaPad 3', 'Gundelik kullanim laptopu', 22999.9, 18500.0, 14, 3, 'active'),
(10, 7, 'SKU-LAP-050', 'HP Pavilion 15', 'Performans laptopu', 24999.9, 20000.0, 12, 3, 'active'),
(11, 7, 'SKU-LAP-051', 'Asus VivoBook', 'Ince ve hafif laptop', 21999.9, 17500.0, 18, 3, 'active'),
(12, 7, 'SKU-LAP-052', 'Acer Aspire 5', 'Gundelik laptop', 19999.9, 16000.0, 20, 4, 'active'),
(13, 7, 'SKU-LAP-053', 'Dell Inspiron 15', 'Ofis laptopu', 25999.9, 21000.0, 10, 2, 'active'),
(14, 7, 'SKU-LAP-054', 'MacBook Air M2', 'Apple dizustu bilgisayar', 37999.9, 31000.0, 8, 2, 'active'),
(15, 7, 'SKU-LAP-055', 'MSI Gaming Laptop', 'Oyuncu laptopu', 49999.9, 41000.0, 6, 2, 'active'),
(16, 7, 'SKU-LAP-056', 'Huawei MateBook', 'Huawei dizustu bilgisayar', 27999.9, 22500.0, 9, 2, 'active'),
(17, 8, 'SKU-WOM-057', 'Kadin Spor Ayakkabi', 'Gunluk spor ayakkabi', 1799.9, 950.0, 35, 7, 'active'),
(18, 8, 'SKU-WOM-058', 'Kadin Elbise', 'Gunluk yazlik elbise', 1499.9, 750.0, 40, 8, 'active'),
(19, 8, 'SKU-WOM-059', 'Kadin Canta', 'Omuz cantasi', 1299.9, 650.0, 30, 6, 'active'),
(20, 8, 'SKU-WOM-060', 'Kadin Cuzdan', 'Deri cuzdan', 699.9, 320.0, 45, 8, 'active'),
(1, 8, 'SKU-WOM-061', 'Kadin Gunes Gozlugu', 'UV korumali gunes gozlugu', 899.9, 420.0, 55, 10, 'active'),
(2, 8, 'SKU-WOM-062', 'Kadin Saat', 'Klasik kol saati', 1999.9, 1050.0, 20, 4, 'active'),
(3, 8, 'SKU-WOM-063', 'Kadin Hirka', 'Yumusak triko hirka', 999.9, 500.0, 50, 10, 'active'),
(4, 8, 'SKU-WOM-064', 'Kadin Esarp', 'Desenli esarp', 399.9, 170.0, 75, 15, 'active'),
(5, 9, 'SKU-MEN-065', 'Erkek Spor Ayakkabi', 'Erkek kosu ayakkabisi', 1899.9, 1000.0, 40, 8, 'active'),
(6, 9, 'SKU-MEN-066', 'Erkek Gömlek', 'Klasik erkek gomlegi', 899.9, 450.0, 50, 10, 'active'),
(7, 9, 'SKU-MEN-067', 'Erkek Ceket', 'Klasik erkek ceketi', 2499.9, 1300.0, 25, 5, 'active'),
(8, 9, 'SKU-MEN-068', 'Erkek Cuzdan', 'Deri erkek cuzdan', 699.9, 320.0, 60, 12, 'active'),
(9, 9, 'SKU-MEN-069', 'Erkek Kemer', 'Deri kemer', 499.9, 220.0, 70, 12, 'active'),
(10, 9, 'SKU-MEN-070', 'Erkek Saat', 'Klasik erkek saati', 2199.9, 1200.0, 18, 4, 'active'),
(11, 9, 'SKU-MEN-071', 'Erkek Kazak', 'Kislik erkek kazagi', 1199.9, 600.0, 35, 7, 'active'),
(12, 9, 'SKU-MEN-072', 'Erkek Polo Tisort', 'Polo yaka tisort', 799.9, 390.0, 65, 12, 'active'),
(13, 10, 'SKU-FUR-073', 'Tek Kisilik Yatak', 'Konforlu tek kisilik yatak', 3999.9, 2500.0, 12, 3, 'active'),
(14, 10, 'SKU-FUR-074', 'Cift Kisilik Yatak', 'Konforlu cift kisilik yatak', 6499.9, 4200.0, 8, 2, 'active'),
(15, 10, 'SKU-FUR-075', 'Ofis Sehpası', 'Modern ofis sehpası', 1299.9, 650.0, 25, 5, 'active'),
(16, 10, 'SKU-FUR-076', 'TV Sehpası', 'Minimal TV sehpası', 1799.9, 900.0, 18, 4, 'active'),
(17, 10, 'SKU-FUR-077', 'Ayakkabilik', 'Bes rafli ayakkabilik', 1599.9, 800.0, 20, 4, 'active'),
(18, 10, 'SKU-FUR-078', 'Mutfak Masasi', 'Dort kisilik mutfak masasi', 2999.9, 1750.0, 15, 3, 'active'),
(19, 10, 'SKU-FUR-079', 'Bar Taburesi', 'Metal bar taburesi', 899.9, 450.0, 30, 6, 'active'),
(20, 10, 'SKU-FUR-080', 'Konsol', 'Modern salon konsolu', 3499.9, 2200.0, 7, 2, 'active'),
(1, 11, 'SKU-KIT-081', 'Tencere Seti', 'Paslanmaz celik tencere seti', 2999.9, 1650.0, 20, 4, 'active'),
(2, 11, 'SKU-KIT-082', 'Tava Seti', 'Yapismayan tava seti', 1899.9, 950.0, 30, 6, 'active'),
(3, 11, 'SKU-KIT-083', 'Blender', 'Guclu mutfak blenderi', 1499.9, 750.0, 35, 7, 'active'),
(4, 11, 'SKU-KIT-084', 'Kahve Makinesi', 'Filtre kahve makinesi', 2499.9, 1350.0, 22, 4, 'active'),
(5, 11, 'SKU-KIT-085', 'Elektrikli Su Isitici', 'Cam kettle', 899.9, 420.0, 45, 8, 'active'),
(6, 11, 'SKU-KIT-086', 'Mikser', 'Mutfak mikseri', 1199.9, 600.0, 25, 5, 'active'),
(7, 11, 'SKU-KIT-087', 'Ekmek Kizartma Makinesi', 'Iki dilimli tost makinesi', 999.9, 500.0, 28, 5, 'active'),
(8, 11, 'SKU-KIT-088', 'Mutfak Robotu', 'Cok fonksiyonlu mutfak robotu', 2999.9, 1600.0, 15, 3, 'active'),
(9, 12, 'SKU-FIT-089', 'Koşu Bandi', 'Ev tipi kosu bandi', 15999.9, 10500.0, 7, 2, 'active'),
(10, 12, 'SKU-FIT-090', 'Egzersiz Bisikleti', 'Ev tipi kondisyon bisikleti', 8999.9, 5600.0, 10, 2, 'active'),
(11, 12, 'SKU-FIT-091', 'Pilates Topu', 'Pilates egzersiz topu', 499.9, 220.0, 70, 12, 'active'),
(12, 12, 'SKU-FIT-092', 'Direnc Bandi Seti', 'Besli direnç bandi seti', 599.9, 280.0, 65, 12, 'active'),
(13, 12, 'SKU-FIT-093', 'Fitness Matı', 'Kalın fitness matı', 799.9, 380.0, 50, 10, 'active'),
(14, 12, 'SKU-FIT-094', 'Kettlebell 12kg', 'Döküm kettlebell', 999.9, 520.0, 30, 6, 'active'),
(15, 12, 'SKU-FIT-095', 'Kettlebell 16kg', 'Agirlik kettlebell', 1299.9, 680.0, 24, 5, 'active'),
(16, 12, 'SKU-FIT-096', 'Barfiks Demiri', 'Kapi tipi barfiks demiri', 699.9, 350.0, 40, 8, 'active'),
(17, 13, 'SKU-OUT-097', 'Kamp Cadiri', 'Dort kisilik kamp cadiri', 3499.9, 2000.0, 15, 3, 'active'),
(18, 13, 'SKU-OUT-098', 'Uyku Tulumu', 'Dort mevsim uyku tulumu', 1999.9, 1050.0, 25, 5, 'active'),
(19, 13, 'SKU-OUT-099', 'Kamp Sandalyesi', 'Katlanabilir kamp sandalyesi', 799.9, 380.0, 45, 8, 'active'),
(20, 13, 'SKU-OUT-100', 'Kamp Masasi', 'Katlanabilir kamp masasi', 999.9, 500.0, 30, 6, 'active'),
(1, 13, 'SKU-OUT-101', 'Trekking Cantasi', '50 litre trekking cantasi', 2499.9, 1350.0, 18, 4, 'active'),
(2, 13, 'SKU-OUT-102', 'El Feneri', 'LED kamp feneri', 499.9, 220.0, 80, 15, 'active'),
(3, 13, 'SKU-OUT-103', 'Termos', '1 litre celik termos', 699.9, 320.0, 60, 12, 'active'),
(4, 13, 'SKU-OUT-104', 'Pusula', 'Profesyonel kamp pusulasi', 399.9, 160.0, 35, 7, 'active'),
(5, 14, 'SKU-EDU-105', 'Matematik Soru Bankasi', 'Lise matematik soru bankasi', 299.9, 140.0, 90, 15, 'active'),
(6, 14, 'SKU-EDU-106', 'Fizik Soru Bankasi', 'Lise fizik soru bankasi', 299.9, 140.0, 80, 15, 'active'),
(7, 14, 'SKU-EDU-107', 'Kimya Soru Bankasi', 'Lise kimya soru bankasi', 299.9, 140.0, 75, 15, 'active'),
(8, 14, 'SKU-EDU-108', 'Biyoloji Soru Bankasi', 'Lise biyoloji soru bankasi', 299.9, 140.0, 70, 12, 'active'),
(9, 14, 'SKU-EDU-109', 'Ingilizce Gramer', 'Ingilizce gramer kitabi', 349.9, 170.0, 65, 12, 'active'),
(10, 14, 'SKU-EDU-110', 'YDS Hazirlik', 'YDS sinavi hazirlik kitabi', 449.9, 230.0, 50, 10, 'active'),
(11, 14, 'SKU-EDU-111', 'TYT Deneme', 'TYT deneme sinavi kitabi', 249.9, 120.0, 100, 20, 'active'),
(12, 14, 'SKU-EDU-112', 'AYT Deneme', 'AYT deneme sinavi kitabi', 249.9, 120.0, 95, 20, 'active'),
(13, 15, 'SKU-GEN-113', 'Akilli Saat', 'Bluetooth destekli akilli saat', 2499.9, 1350.0, 25, 5, 'active'),
(14, 15, 'SKU-GEN-114', 'Masa Lambasi', 'LED masa lambasi', 599.9, 280.0, 45, 8, 'active'),
(15, 15, 'SKU-GEN-115', 'Sirt Cantasi', 'Gunluk kullanim sirt cantasi', 899.9, 420.0, 50, 10, 'active'),
(16, 15, 'SKU-GEN-116', 'Cok Amacli Organizer', 'Ev ve ofis organizeri', 399.9, 180.0, 70, 12, 'active'),
(17, 15, 'SKU-GEN-117', 'Bluetooth Hoparlor', 'Tasınabilir bluetooth hoparlor', 1499.9, 750.0, 35, 7, 'active'),
(18, 15, 'SKU-GEN-118', 'Masaustu Saat', 'Dijital masaustu saat', 499.9, 230.0, 55, 10, 'active'),
(19, 15, 'SKU-GEN-119', 'Kablosuz Mouse', 'Ergonomik kablosuz mouse', 699.9, 350.0, 65, 12, 'active'),
(20, 15, 'SKU-GEN-120', 'Mekanik Klavye', 'RGB mekanik klavye', 1799.9, 950.0, 30, 6, 'active');

INSERT INTO product_price_history
(product_id, old_price, new_price)
VALUES
(1, 8499.9, 8999.9),
(2, 41999.9, 42999.9),
(3, 10499.9, 10999.9),
(4, 14499.9, 14999.9),
(5, 15999.9, 16999.9),
(6, 33999.9, 34999.9),
(7, 26999.9, 27999.9),
(8, 17999.9, 18999.9),
(9, 449.9, 499.9),
(10, 449.9, 499.9),
(11, 1199.9, 1299.9),
(12, 1299.9, 1399.9),
(13, 2299.9, 2499.9),
(14, 2799.9, 2999.9),
(15, 899.9, 999.9),
(16, 899.9, 999.9),
(17, 8499.9, 8999.9),
(18, 6199.9, 6499.9),
(19, 3299.9, 3499.9),
(20, 1799.9, 1999.9),
(21, 3799.9, 3999.9),
(22, 1399.9, 1499.9),
(23, 5699.9, 5999.9),
(24, 2599.9, 2799.9),
(25, 649.9, 699.9),
(26, 1499.9, 1599.9),
(27, 2299.9, 2499.9),
(28, 799.9, 899.9),
(29, 899.9, 999.9),
(30, 349.9, 399.9),
(31, 699.9, 799.9),
(32, 1099.9, 1199.9),
(33, 299.9, 349.9),
(34, 399.9, 449.9),
(35, 449.9, 499.9),
(36, 349.9, 399.9),
(37, 499.9, 549.9),
(38, 549.9, 599.9),
(39, 429.9, 479.9),
(40, 599.9, 649.9);

INSERT INTO carts
(customer_id, status)
VALUES
(1, 'active'),
(2, 'active'),
(3, 'converted'),
(4, 'abandoned'),
(5, 'active'),
(6, 'converted'),
(7, 'active'),
(8, 'active'),
(9, 'abandoned'),
(10, 'converted'),
(11, 'active'),
(12, 'active'),
(13, 'converted'),
(14, 'abandoned'),
(15, 'active'),
(16, 'active'),
(17, 'converted'),
(18, 'active'),
(19, 'abandoned'),
(20, 'active'),
(21, 'converted'),
(22, 'active'),
(23, 'active'),
(24, 'abandoned'),
(25, 'converted'),
(26, 'active'),
(27, 'active'),
(28, 'converted'),
(29, 'abandoned'),
(30, 'active'),
(31, 'active'),
(32, 'converted'),
(33, 'active'),
(34, 'abandoned'),
(35, 'active'),
(36, 'converted'),
(37, 'active'),
(38, 'active'),
(39, 'abandoned'),
(40, 'converted'),
(41, 'active'),
(42, 'active'),
(43, 'converted'),
(44, 'abandoned'),
(45, 'active'),
(46, 'converted'),
(47, 'active'),
(48, 'active'),
(49, 'abandoned'),
(50, 'converted');

INSERT INTO cart_items
(cart_id, product_id, quantity)
VALUES
(1, 1, 5),
(1, 12, 3),
(1, 25, 7),
(1, 44, 4),
(2, 2, 6),
(2, 18, 4),
(2, 31, 8),
(2, 55, 5),
(3, 3, 9),
(3, 20, 4),
(3, 42, 6),
(3, 67, 3),
(4, 4, 5),
(4, 15, 7),
(4, 38, 4),
(4, 72, 9),
(5, 5, 3),
(5, 29, 8),
(5, 48, 6),
(5, 91, 4),
(6, 6, 7),
(6, 24, 5),
(6, 51, 3),
(6, 80, 6),
(7, 7, 4),
(7, 16, 9),
(7, 35, 5),
(7, 63, 7),
(8, 8, 6),
(8, 27, 3),
(8, 46, 8),
(8, 74, 5),
(9, 9, 4),
(9, 21, 7),
(9, 58, 5),
(9, 86, 9),
(10, 10, 8),
(10, 33, 4),
(10, 61, 6),
(10, 95, 3),
(11, 11, 5),
(11, 19, 7),
(11, 43, 4),
(11, 69, 8),
(12, 13, 6),
(12, 28, 5),
(12, 54, 9),
(12, 82, 4),
(13, 14, 3),
(13, 37, 6),
(13, 52, 7),
(13, 77, 5),
(14, 15, 8),
(14, 32, 4),
(14, 66, 5),
(14, 104, 7),
(15, 16, 5),
(15, 41, 9),
(15, 59, 4),
(15, 88, 6),
(16, 17, 7),
(16, 30, 3),
(16, 56, 8),
(16, 101, 5),
(17, 19, 4),
(17, 26, 6),
(17, 73, 5),
(17, 109, 8),
(18, 21, 9),
(18, 45, 4),
(18, 70, 6),
(18, 93, 5),
(19, 22, 5),
(19, 39, 7),
(19, 64, 3),
(19, 98, 6),
(20, 23, 8),
(20, 34, 5),
(20, 57, 4),
(20, 84, 7),
(21, 24, 6),
(21, 49, 3),
(21, 76, 8),
(21, 107, 5),
(22, 26, 4),
(22, 40, 7),
(22, 68, 6),
(22, 96, 9),
(23, 28, 5),
(23, 53, 8),
(23, 71, 4),
(23, 113, 6),
(24, 30, 7),
(24, 47, 5),
(24, 79, 3),
(24, 115, 8),
(25, 32, 6),
(25, 44, 4),
(25, 81, 7),
(25, 102, 5),
(26, 33, 8),
(26, 50, 3),
(26, 65, 6),
(26, 118, 4),
(27, 34, 5),
(27, 62, 9),
(27, 83, 4),
(27, 111, 7),
(28, 36, 6),
(28, 55, 5),
(28, 78, 8),
(28, 105, 3),
(29, 38, 4),
(29, 46, 7),
(29, 85, 5),
(29, 120, 6),
(30, 40, 9),
(30, 59, 3),
(30, 90, 7),
(30, 114, 5),
(31, 41, 6),
(31, 52, 4),
(31, 87, 8),
(31, 108, 5),
(32, 43, 7),
(32, 63, 3),
(32, 94, 6),
(32, 116, 4),
(33, 45, 5),
(33, 58, 8),
(33, 75, 4),
(33, 100, 7),
(34, 47, 6),
(34, 69, 5),
(34, 92, 3),
(34, 119, 8),
(35, 50, 4),
(35, 60, 7),
(35, 89, 5),
(35, 103, 6),
(36, 52, 8),
(36, 73, 4),
(36, 99, 7),
(36, 112, 5),
(37, 54, 6),
(37, 68, 3),
(37, 86, 8),
(37, 117, 4),
(38, 56, 5),
(38, 77, 7),
(38, 91, 4),
(38, 110, 6),
(39, 59, 9),
(39, 74, 5),
(39, 97, 3),
(39, 106, 7),
(40, 62, 4),
(40, 80, 6),
(40, 104, 5),
(40, 118, 8),
(41, 64, 7),
(41, 71, 4),
(41, 93, 6),
(41, 109, 5),
(42, 65, 5),
(42, 83, 8),
(42, 95, 3),
(42, 115, 7),
(43, 67, 6),
(43, 76, 4),
(43, 88, 9),
(43, 113, 5),
(44, 71, 8),
(44, 82, 3),
(44, 101, 6),
(44, 116, 4),
(45, 74, 5),
(45, 85, 7),
(45, 99, 4),
(45, 120, 8),
(46, 78, 6),
(46, 89, 3),
(46, 105, 5),
(46, 114, 7),
(47, 79, 4),
(47, 92, 8),
(47, 103, 6),
(47, 118, 5),
(48, 81, 7),
(48, 96, 4),
(48, 107, 6),
(48, 119, 3),
(49, 85, 5),
(49, 98, 7),
(49, 110, 4),
(49, 117, 8),
(50, 87, 6),
(50, 100, 3),
(50, 108, 7),
(50, 120, 5);

INSERT INTO coupons
(code, discount_type, discount_value, minimum_order, maximum_discount, usage_limit, used_count, starts_at, expires_at, status)
VALUES
('WELCOME10', 'percentage', 10.0, 50.0, 30.0, 100, 15, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 'active'),
('SAVE20', 'percentage', 20.0, 100.0, 50.0, 80, 20, '2026-02-01 00:00:00', '2026-12-31 23:59:59', 'active'),
('FIXED15', 'fixed', 15.0, 60.0, NULL, 50, 10, '2026-03-01 00:00:00', '2026-11-30 23:59:59', 'active'),
('SHOP25', 'percentage', 25.0, 150.0, 70.0, 60, 25, '2026-01-15 00:00:00', '2026-10-31 23:59:59', 'active'),
('NEWUSER', 'fixed', 20.0, 80.0, NULL, 150, 45, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 'active'),
('SUMMER15', 'percentage', 15.0, 70.0, 40.0, 120, 50, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 'active'),
('VIP30', 'percentage', 30.0, 300.0, 100.0, 30, 12, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 'active'),
('DEAL10', 'fixed', 10.0, 40.0, NULL, 200, 90, '2026-04-01 00:00:00', '2026-12-01 23:59:59', 'active'),
('FLASH20', 'percentage', 20.0, 120.0, 45.0, 40, 18, '2026-09-01 00:00:00', '2026-10-15 23:59:59', 'active'),
('BIGSAVE', 'fixed', 50.0, 250.0, NULL, 35, 14, '2026-05-01 00:00:00', '2026-12-31 23:59:59', 'active'),
('FASHION12', 'percentage', 12.0, 90.0, 35.0, 75, 30, '2026-03-01 00:00:00', '2026-11-30 23:59:59', 'active'),
('TECH40', 'fixed', 40.0, 200.0, NULL, 45, 22, '2026-02-15 00:00:00', '2026-12-15 23:59:59', 'active'),
('SPECIAL18', 'percentage', 18.0, 110.0, 55.0, 90, 35, '2026-01-20 00:00:00', '2026-12-20 23:59:59', 'active'),
('WEEKEND25', 'fixed', 25.0, 100.0, NULL, 70, 28, '2026-07-01 00:00:00', '2026-10-31 23:59:59', 'active'),
('MEGA35', 'percentage', 35.0, 400.0, 120.0, 25, 8, '2026-08-01 00:00:00', '2026-12-31 23:59:59', 'active');

INSERT INTO orders
(order_number, customer_id, address_id, coupon_id, subtotal, discount_amount, shipping_cost, total_amount, status)
VALUES
('ORD-2026-0001', 1, 1, 1, 21729.50, 30.00, 49.9, 21749.40, 'delivered'),
('ORD-2026-0002', 2, 2, NULL, 90954.10, 0.00, 59.9, 91014.00, 'delivered'),
('ORD-2026-0003', 3, 3, 2, 11339.40, 50.00, 0.0, 11289.40, 'delivered'),
('ORD-2026-0004', 4, 4, NULL, 3454.60, 0.00, 39.9, 3494.50, 'delivered'),
('ORD-2026-0005', 5, 5, 6, 5744.40, 40.00, 49.9, 5754.30, 'delivered'),
('ORD-2026-0006', 6, 6, 3, 191964.00, 15.00, 0.0, 191949.00, 'delivered'),
('ORD-2026-0007', 7, 7, NULL, 2929.60, 0.00, 34.9, 2964.50, 'delivered'),
('ORD-2026-0008', 8, 8, 4, 51439.30, 70.00, 49.9, 51419.20, 'delivered'),
('ORD-2026-0009', 9, 9, NULL, 7649.20, 0.00, 59.9, 7709.10, 'delivered'),
('ORD-2026-0010', 10, 10, 7, 2029.60, 100.00, 0.0, 1929.60, 'delivered'),
('ORD-2026-0011', 11, 11, NULL, 4169.40, 0.00, 39.9, 4209.30, 'delivered'),
('ORD-2026-0012', 12, 12, 1, 245959.20, 30.00, 49.9, 245979.10, 'delivered'),
('ORD-2026-0013', 13, 13, 5, 3914.70, 20.00, 0.0, 3894.70, 'shipped'),
('ORD-2026-0014', 14, 14, NULL, 94264.00, 0.00, 39.9, 94303.90, 'delivered'),
('ORD-2026-0015', 15, 15, 8, 26939.40, 10.00, 49.9, 26979.30, 'delivered'),
('ORD-2026-0016', 16, 16, NULL, 8834.70, 0.00, 44.9, 8879.60, 'delivered'),
('ORD-2026-0017', 17, 17, 9, 78559.00, 45.00, 0.0, 78514.00, 'delivered'),
('ORD-2026-0018', 18, 18, NULL, 14739.40, 0.00, 34.9, 14774.30, 'delivered'),
('ORD-2026-0019', 19, 19, 10, 729.70, 50.00, 49.9, 729.60, 'delivered'),
('ORD-2026-0020', 20, 20, NULL, 68464.00, 0.00, 0.0, 68464.00, 'delivered'),
('ORD-2026-0021', 21, 21, 11, 6344.40, 35.00, 39.9, 6349.30, 'delivered'),
('ORD-2026-0022', 22, 22, NULL, 63619.70, 0.00, 59.9, 63679.60, 'delivered'),
('ORD-2026-0023', 23, 23, 12, 22959.10, 40.00, 0.0, 22919.10, 'delivered'),
('ORD-2026-0024', 24, 24, NULL, 18409.50, 0.00, 34.9, 18444.40, 'delivered'),
('ORD-2026-0025', 25, 25, 13, 4709.50, 55.00, 39.9, 4694.40, 'delivered'),
('ORD-2026-0026', 26, 26, NULL, 4874.10, 0.00, 49.9, 4924.00, 'delivered'),
('ORD-2026-0027', 27, 27, 14, 4714.50, 25.00, 0.0, 4689.50, 'delivered'),
('ORD-2026-0028', 28, 28, NULL, 89539.40, 0.00, 44.9, 89584.30, 'shipped'),
('ORD-2026-0029', 29, 29, 15, 11864.10, 120.00, 49.9, 11794.00, 'delivered'),
('ORD-2026-0030', 30, 30, NULL, 7124.50, 0.00, 39.9, 7164.40, 'delivered'),
('ORD-2026-0031', 31, 31, 1, 25829.60, 30.00, 49.9, 25849.50, 'delivered'),
('ORD-2026-0032', 32, 32, NULL, 7859.30, 0.00, 0.0, 7859.30, 'delivered'),
('ORD-2026-0033', 33, 33, 2, 15044.30, 50.00, 59.9, 15054.20, 'delivered'),
('ORD-2026-0034', 34, 34, NULL, 2524.60, 0.00, 34.9, 2559.50, 'delivered'),
('ORD-2026-0035', 35, 35, 6, 3454.20, 40.00, 49.9, 3464.10, 'delivered'),
('ORD-2026-0036', 36, 36, NULL, 4959.20, 0.00, 44.9, 5004.10, 'delivered'),
('ORD-2026-0037', 37, 37, 3, 79909.60, 15.00, 0.0, 79894.60, 'delivered'),
('ORD-2026-0038', 38, 38, NULL, 19239.20, 0.00, 39.9, 19279.10, 'delivered'),
('ORD-2026-0039', 39, 39, 4, 17154.30, 70.00, 49.9, 17134.20, 'delivered'),
('ORD-2026-0040', 40, 40, NULL, 3514.60, 0.00, 0.0, 3514.60, 'delivered'),
('ORD-2026-0041', 41, 41, 7, 4699.20, 100.00, 39.9, 4639.10, 'delivered'),
('ORD-2026-0042', 42, 42, NULL, 5954.40, 0.00, 49.9, 6004.30, 'delivered'),
('ORD-2026-0043', 43, 43, 8, 57114.40, 10.00, 0.0, 57104.40, 'delivered'),
('ORD-2026-0044', 44, 44, NULL, 6724.20, 0.00, 34.9, 6759.10, 'delivered'),
('ORD-2026-0045', 45, 45, 9, 2984.30, 45.00, 49.9, 2989.20, 'delivered'),
('ORD-2026-0046', 46, 46, NULL, 6119.60, 0.00, 44.9, 6164.50, 'delivered'),
('ORD-2026-0047', 47, 47, 10, 40364.30, 50.00, 0.0, 40314.30, 'shipped'),
('ORD-2026-0048', 48, 48, NULL, 10659.30, 0.00, 39.9, 10699.20, 'delivered'),
('ORD-2026-0049', 49, 49, 11, 8919.60, 35.00, 49.9, 8934.50, 'delivered'),
('ORD-2026-0050', 50, 50, NULL, 3394.20, 0.00, 59.9, 3454.10, 'delivered'),
('ORD-2026-0051', 1, 1, NULL, 43154.20, 0.00, 39.9, 43194.10, 'delivered'),
('ORD-2026-0052', 2, 2, 12, 17934.60, 40.00, 0.0, 17894.60, 'delivered'),
('ORD-2026-0053', 3, 3, NULL, 38544.30, 0.00, 44.9, 38589.20, 'processing'),
('ORD-2026-0054', 4, 4, 13, 12349.30, 55.00, 39.9, 12334.20, 'delivered'),
('ORD-2026-0055', 5, 5, NULL, 5864.60, 0.00, 0.0, 5864.60, 'delivered'),
('ORD-2026-0056', 6, 6, 14, 8144.10, 25.00, 49.9, 8169.00, 'delivered'),
('ORD-2026-0057', 7, 7, NULL, 58944.30, 0.00, 34.9, 58979.20, 'delivered'),
('ORD-2026-0058', 8, 8, 15, 21924.60, 120.00, 0.0, 21804.60, 'delivered'),
('ORD-2026-0059', 9, 9, NULL, 6954.30, 0.00, 49.9, 7004.20, 'delivered'),
('ORD-2026-0060', 10, 10, 1, 9554.20, 30.00, 0.0, 9524.20, 'delivered'),
('ORD-2026-0061', 11, 11, NULL, 6499.60, 0.00, 39.9, 6539.50, 'delivered'),
('ORD-2026-0062', 12, 12, 2, 27739.10, 50.00, 49.9, 27739.00, 'delivered'),
('ORD-2026-0063', 13, 13, NULL, 3439.30, 0.00, 44.9, 3484.20, 'delivered'),
('ORD-2026-0064', 14, 14, 6, 19189.60, 40.00, 0.0, 19149.60, 'delivered'),
('ORD-2026-0065', 15, 15, NULL, 9039.30, 0.00, 39.9, 9079.20, 'delivered'),
('ORD-2026-0066', 16, 16, 7, 61554.20, 100.00, 49.9, 61504.10, 'delivered'),
('ORD-2026-0067', 17, 17, NULL, 12884.60, 0.00, 0.0, 12884.60, 'delivered'),
('ORD-2026-0068', 18, 18, 8, 29739.10, 10.00, 59.9, 29789.00, 'delivered'),
('ORD-2026-0069', 19, 19, NULL, 122534.30, 0.00, 34.9, 122569.20, 'delivered'),
('ORD-2026-0070', 20, 20, 9, 4899.60, 45.00, 0.0, 4854.60, 'delivered'),
('ORD-2026-0071', 21, 21, NULL, 4459.30, 0.00, 44.9, 4504.20, 'processing'),
('ORD-2026-0072', 22, 22, 10, 105144.30, 50.00, 49.9, 105144.20, 'delivered'),
('ORD-2026-0073', 23, 23, NULL, 27914.60, 0.00, 39.9, 27954.50, 'delivered'),
('ORD-2026-0074', 24, 24, 11, 9144.20, 35.00, 0.0, 9109.20, 'delivered'),
('ORD-2026-0075', 25, 25, NULL, 9959.20, 0.00, 34.9, 9994.10, 'delivered'),
('ORD-2026-0076', 26, 26, 12, 2809.60, 40.00, 49.9, 2819.50, 'processing'),
('ORD-2026-0077', 27, 27, NULL, 10429.20, 0.00, 0.0, 10429.20, 'shipped'),
('ORD-2026-0078', 28, 28, 13, 131349.30, 55.00, 39.9, 131334.20, 'delivered'),
('ORD-2026-0079', 29, 29, NULL, 38969.60, 0.00, 49.9, 39019.50, 'delivered'),
('ORD-2026-0080', 30, 30, 14, 3939.30, 25.00, 0.0, 3914.30, 'delivered'),
('ORD-2026-0081', 31, 31, NULL, 95754.20, 0.00, 39.9, 95794.10, 'delivered'),
('ORD-2026-0082', 32, 32, 15, 47519.60, 120.00, 49.9, 47449.50, 'delivered'),
('ORD-2026-0083', 33, 33, NULL, 8544.10, 0.00, 44.9, 8589.00, 'delivered'),
('ORD-2026-0084', 34, 34, 1, 16149.30, 30.00, 0.0, 16119.30, 'delivered'),
('ORD-2026-0085', 35, 35, NULL, 46114.60, 0.00, 34.9, 46149.50, 'shipped'),
('ORD-2026-0086', 36, 36, 2, 5004.30, 50.00, 49.9, 5004.20, 'delivered'),
('ORD-2026-0087', 37, 37, NULL, 86039.30, 0.00, 0.0, 86039.30, 'delivered'),
('ORD-2026-0088', 38, 38, 6, 29514.60, 40.00, 39.9, 29514.50, 'delivered'),
('ORD-2026-0089', 39, 39, NULL, 15139.20, 0.00, 59.9, 15199.10, 'delivered'),
('ORD-2026-0090', 40, 40, 7, 43749.20, 100.00, 0.0, 43649.20, 'delivered'),
('ORD-2026-0091', 41, 41, NULL, 14619.60, 0.00, 39.9, 14659.50, 'delivered'),
('ORD-2026-0092', 42, 42, 8, 10834.20, 10.00, 49.9, 10874.10, 'processing'),
('ORD-2026-0093', 43, 43, NULL, 26439.30, 0.00, 44.9, 26484.20, 'delivered'),
('ORD-2026-0094', 44, 44, 9, 5974.60, 45.00, 0.0, 5929.60, 'delivered'),
('ORD-2026-0095', 45, 45, NULL, 19349.30, 0.00, 39.9, 19389.20, 'delivered'),
('ORD-2026-0096', 46, 46, 10, 47154.20, 50.00, 49.9, 47154.10, 'delivered'),
('ORD-2026-0097', 47, 47, NULL, 14604.60, 0.00, 34.9, 14639.50, 'processing'),
('ORD-2026-0098', 48, 48, 11, 18399.10, 35.00, 49.9, 18414.00, 'shipped'),
('ORD-2026-0099', 49, 49, NULL, 20549.30, 0.00, 39.9, 20589.20, 'delivered'),
('ORD-2026-0100', 50, 50, 12, 51159.60, 40.00, 0.0, 51119.60, 'delivered'),
('ORD-2026-0101', 1, 1, NULL, 4439.60, 0.00, 49.9, 4489.50, 'delivered'),
('ORD-2026-0102', 2, 2, 4, 54669.50, 70.00, 0.0, 54599.50, 'delivered'),
('ORD-2026-0103', 3, 3, NULL, 13849.70, 0.00, 39.9, 13889.60, 'shipped'),
('ORD-2026-0104', 4, 4, 7, 4959.50, 100.00, 49.9, 4909.40, 'delivered'),
('ORD-2026-0105', 5, 5, NULL, 67169.40, 0.00, 0.0, 67169.40, 'delivered'),
('ORD-2026-0106', 6, 6, 2, 2254.70, 50.00, 39.9, 2244.60, 'shipped'),
('ORD-2026-0107', 7, 7, NULL, 3049.60, 0.00, 59.9, 3109.50, 'shipped'),
('ORD-2026-0108', 8, 8, 9, 5714.50, 45.00, 0.0, 5669.50, 'delivered'),
('ORD-2026-0109', 9, 9, NULL, 1684.70, 0.00, 39.9, 1724.60, 'shipped'),
('ORD-2026-0110', 10, 10, 5, 39464.60, 20.00, 49.9, 39494.50, 'delivered'),
('ORD-2026-0111', 11, 11, NULL, 37474.50, 0.00, 59.9, 37534.40, 'delivered'),
('ORD-2026-0112', 12, 12, 3, 9349.70, 15.00, 39.9, 9374.60, 'delivered'),
('ORD-2026-0113', 13, 13, NULL, 8949.50, 0.00, 0.0, 8949.50, 'processing'),
('ORD-2026-0114', 14, 14, 8, 3969.40, 10.00, 49.9, 4009.30, 'delivered'),
('ORD-2026-0115', 15, 15, NULL, 2339.70, 0.00, 39.9, 2379.60, 'delivered'),
('ORD-2026-0116', 16, 16, 1, 26409.60, 30.00, 0.0, 26379.60, 'delivered'),
('ORD-2026-0117', 17, 17, NULL, 42664.50, 0.00, 59.9, 42724.40, 'delivered'),
('ORD-2026-0118', 18, 18, 6, 1659.70, 40.00, 39.9, 1659.60, 'delivered'),
('ORD-2026-0119', 19, 19, NULL, 4549.50, 0.00, 49.9, 4599.40, 'shipped'),
('ORD-2026-0120', 20, 20, 10, 8064.50, 50.00, 0.0, 8014.50, 'delivered'),
('ORD-2026-0121', 21, 21, NULL, 3449.70, 0.00, 39.9, 3489.60, 'shipped'),
('ORD-2026-0122', 22, 22, 12, 2569.60, 40.00, 49.9, 2579.50, 'delivered'),
('ORD-2026-0123', 23, 23, NULL, 3164.40, 0.00, 39.9, 3204.30, 'delivered'),
('ORD-2026-0124', 24, 24, 4, 2039.70, 70.00, 0.0, 1969.70, 'delivered'),
('ORD-2026-0125', 25, 25, NULL, 12159.60, 0.00, 59.9, 12219.50, 'shipped'),
('ORD-2026-0126', 26, 26, 7, 26174.50, 100.00, 39.9, 26114.40, 'delivered'),
('ORD-2026-0127', 27, 27, NULL, 5249.70, 0.00, 49.9, 5299.60, 'delivered'),
('ORD-2026-0128', 28, 28, 2, 14849.50, 50.00, 0.0, 14799.50, 'delivered'),
('ORD-2026-0129', 29, 29, NULL, 6569.40, 0.00, 39.9, 6609.30, 'delivered'),
('ORD-2026-0130', 30, 30, 11, 744.70, 35.00, 49.9, 759.60, 'delivered'),
('ORD-2026-0131', 31, 31, NULL, 20554.60, 0.00, 39.9, 20594.50, 'shipped'),
('ORD-2026-0132', 32, 32, 5, 46074.50, 20.00, 0.0, 46054.50, 'delivered'),
('ORD-2026-0133', 33, 33, NULL, 2649.70, 0.00, 49.9, 2699.60, 'processing'),
('ORD-2026-0134', 34, 34, 9, 11759.50, 45.00, 39.9, 11754.40, 'delivered'),
('ORD-2026-0135', 35, 35, NULL, 12569.40, 0.00, 59.9, 12629.30, 'delivered'),
('ORD-2026-0136', 36, 36, 3, 2634.70, 15.00, 0.0, 2619.70, 'delivered'),
('ORD-2026-0137', 37, 37, NULL, 2444.60, 0.00, 39.9, 2484.50, 'delivered'),
('ORD-2026-0138', 38, 38, 8, 2469.50, 10.00, 49.9, 2509.40, 'delivered'),
('ORD-2026-0139', 39, 39, NULL, 1059.70, 0.00, 39.9, 1099.60, 'shipped'),
('ORD-2026-0140', 40, 40, 6, 17659.60, 40.00, 0.0, 17619.60, 'shipped'),
('ORD-2026-0141', 41, 41, NULL, 91169.40, 0.00, 59.9, 91229.30, 'delivered'),
('ORD-2026-0142', 42, 42, 1, 7444.70, 30.00, 39.9, 7454.60, 'delivered'),
('ORD-2026-0143', 43, 43, NULL, 28454.50, 0.00, 49.9, 28504.40, 'delivered'),
('ORD-2026-0144', 44, 44, 10, 4669.50, 50.00, 0.0, 4619.50, 'delivered'),
('ORD-2026-0145', 45, 45, NULL, 799.70, 0.00, 39.9, 839.60, 'confirmed'),
('ORD-2026-0146', 46, 46, 12, 25864.60, 40.00, 49.9, 25874.50, 'delivered'),
('ORD-2026-0147', 47, 47, NULL, 53859.50, 0.00, 59.9, 53919.40, 'delivered'),
('ORD-2026-0148', 48, 48, 4, 6444.70, 70.00, 0.0, 6374.70, 'delivered'),
('ORD-2026-0149', 49, 49, NULL, 3949.60, 0.00, 39.9, 3989.50, 'shipped'),
('ORD-2026-0150', 50, 50, 7, 18969.40, 100.00, 49.9, 18919.30, 'delivered');

INSERT INTO order_items
(order_id, product_id, seller_id, quantity, unit_price, discount_amount, platform_commission, seller_amount, status)
VALUES
(1, 1, 1, 2, 8999.9, 10.00, 1529.13, 16460.67, 'active'),
(1, 12, 12, 1, 1399.9, 20.00, 206.99, 1172.91, 'active'),
(2, 5, 5, 3, 16999.9, 10.00, 3059.38, 47930.32, 'active'),
(3, 18, 18, 1, 6499.9, 30.00, 323.50, 6146.40, 'returned'),
(4, 22, 2, 2, 1499.9, 15.00, 298.48, 2686.32, 'active'),
(5, 30, 10, 1, 399.9, 25.00, 20.62, 354.28, 'active'),
(6, 9, 9, 4, 499.9, 10.00, 268.60, 1721.00, 'active'),
(7, 15, 15, 2, 999.9, 20.00, 178.18, 1801.62, 'active'),
(8, 27, 7, 1, 2499.9, 40.00, 270.59, 2189.31, 'active'),
(9, 35, 15, 3, 499.9, 15.00, 133.62, 1351.08, 'active'),
(10, 40, 20, 2, 649.9, 20.00, 92.79, 1187.01, 'active'),
(11, 48, 8, 1, 899.9, 50.00, 67.99, 781.91, 'active'),
(12, 55, 15, 2, 49999.9, 10.00, 8999.08, 90990.72, 'active'),
(13, 60, 20, 1, 699.9, 20.00, 49.29, 630.61, 'active'),
(14, 7, 7, 3, 27999.9, 10.00, 9238.87, 74750.83, 'active'),
(15, 14, 14, 2, 2999.9, 20.00, 388.69, 5591.11, 'active'),
(16, 21, 1, 1, 3999.9, 15.00, 338.72, 3646.18, 'active'),
(17, 28, 8, 4, 899.9, 10.00, 287.17, 3302.43, 'active'),
(18, 36, 16, 2, 399.9, 25.00, 67.80, 707.00, 'active'),
(19, 44, 4, 1, 149.9, 30.00, 14.39, 105.51, 'active'),
(20, 52, 12, 3, 19999.9, 15.00, 8997.71, 50986.99, 'active'),
(21, 61, 1, 2, 899.9, 20.00, 151.28, 1628.52, 'active'),
(22, 68, 8, 1, 699.9, 25.00, 53.99, 620.91, 'returned'),
(23, 73, 13, 2, 3999.9, 10.00, 559.29, 7430.51, 'active'),
(24, 80, 20, 1, 3499.9, 50.00, 250.12, 3199.78, 'active'),
(25, 86, 6, 3, 1199.9, 15.00, 340.55, 3244.15, 'active'),
(26, 92, 12, 2, 599.9, 20.00, 176.97, 1002.83, 'active'),
(27, 98, 18, 1, 1999.9, 40.00, 98.00, 1861.90, 'active'),
(28, 104, 4, 4, 399.9, 10.00, 190.75, 1398.85, 'active'),
(29, 110, 10, 2, 449.9, 15.00, 48.66, 836.14, 'active'),
(30, 116, 16, 1, 399.9, 30.00, 32.37, 337.53, 'active'),
(31, 3, 3, 2, 10999.9, 10.00, 1649.24, 20340.56, 'active'),
(32, 11, 11, 1, 1299.9, 15.00, 179.89, 1105.01, 'active'),
(33, 19, 19, 3, 3499.9, 10.00, 1311.21, 9178.49, 'active'),
(34, 25, 5, 2, 699.9, 15.00, 83.09, 1301.71, 'active'),
(35, 33, 13, 1, 349.9, 25.00, 22.74, 302.16, 'active'),
(36, 41, 1, 4, 249.9, 10.00, 84.12, 905.48, 'active'),
(37, 49, 9, 2, 22999.9, 20.00, 6207.27, 39772.53, 'active'),
(38, 57, 17, 1, 1799.9, 35.00, 185.31, 1579.59, 'active'),
(39, 64, 4, 3, 399.9, 15.00, 142.16, 1042.54, 'active'),
(40, 72, 12, 2, 799.9, 20.00, 236.97, 1342.83, 'active'),
(41, 79, 19, 1, 899.9, 20.00, 109.99, 769.91, 'active'),
(42, 87, 7, 2, 999.9, 15.00, 218.33, 1766.47, 'active'),
(43, 95, 15, 4, 1299.9, 10.00, 467.06, 4722.54, 'active'),
(44, 102, 2, 1, 499.9, 45.00, 45.49, 409.41, 'returned'),
(45, 109, 9, 3, 349.9, 20.00, 139.01, 890.69, 'active'),
(46, 117, 17, 2, 1499.9, 20.00, 312.88, 2666.92, 'active'),
(47, 6, 6, 1, 34999.9, 15.00, 3323.57, 31661.33, 'active'),
(48, 13, 13, 3, 2499.9, 10.00, 524.28, 6965.42, 'active'),
(49, 20, 20, 2, 1999.9, 20.00, 288.54, 3691.26, 'active'),
(50, 29, 9, 1, 999.9, 30.00, 130.94, 838.96, 'active'),
(51, 37, 17, 4, 549.9, 15.00, 229.38, 1955.22, 'active'),
(52, 45, 5, 2, 999.9, 20.00, 118.79, 1861.01, 'active'),
(53, 53, 13, 1, 25999.9, 25.00, 1818.24, 24156.66, 'active'),
(54, 62, 2, 3, 1999.9, 10.00, 598.97, 5390.73, 'active'),
(55, 70, 10, 2, 2199.9, 20.00, 240.89, 4138.91, 'active'),
(56, 78, 18, 1, 2999.9, 35.00, 148.25, 2816.65, 'active'),
(57, 85, 5, 3, 899.9, 15.00, 161.08, 2523.62, 'active'),
(58, 93, 13, 2, 799.9, 25.00, 110.24, 1464.56, 'active'),
(59, 101, 1, 1, 2499.9, 20.00, 210.79, 2269.11, 'active'),
(60, 108, 8, 4, 299.9, 10.00, 95.17, 1094.43, 'active'),
(61, 115, 15, 2, 899.9, 20.00, 160.18, 1619.62, 'active'),
(62, 4, 4, 1, 14999.9, 40.00, 1795.19, 13164.71, 'active'),
(63, 10, 10, 3, 499.9, 15.00, 81.66, 1403.04, 'active'),
(64, 17, 17, 2, 8999.9, 10.00, 1888.93, 16100.87, 'active'),
(65, 24, 4, 1, 2799.9, 30.00, 332.39, 2437.51, 'active'),
(66, 32, 12, 4, 1199.9, 10.00, 718.44, 4071.16, 'active'),
(67, 39, 19, 2, 479.9, 15.00, 118.10, 826.70, 'active'),
(68, 47, 7, 1, 599.9, 40.00, 61.59, 498.31, 'active'),
(69, 54, 14, 3, 37999.9, 20.00, 7408.68, 106571.02, 'active'),
(70, 63, 3, 2, 999.9, 25.00, 148.11, 1826.69, 'active'),
(71, 71, 11, 1, 1199.9, 15.00, 165.89, 1019.01, 'active'),
(72, 77, 17, 3, 1599.9, 10.00, 502.92, 4286.78, 'active'),
(73, 84, 4, 2, 2499.9, 15.00, 598.18, 4386.62, 'returned'),
(74, 91, 11, 1, 499.9, 30.00, 65.79, 404.11, 'active'),
(75, 99, 19, 4, 799.9, 10.00, 398.70, 2790.90, 'active'),
(76, 106, 6, 2, 299.9, 20.00, 55.08, 524.72, 'active'),
(77, 114, 14, 1, 599.9, 45.00, 36.07, 518.83, 'active'),
(78, 2, 2, 3, 42999.9, 15.00, 12898.47, 116086.23, 'active'),
(79, 8, 8, 2, 18999.9, 10.00, 3039.18, 34950.62, 'active'),
(80, 16, 16, 1, 999.9, 25.00, 85.30, 889.60, 'active'),
(81, 23, 3, 4, 5999.9, 10.00, 1799.22, 22190.38, 'active'),
(82, 31, 11, 2, 799.9, 20.00, 221.17, 1358.63, 'active'),
(83, 38, 18, 1, 599.9, 35.00, 28.25, 536.65, 'active'),
(84, 46, 6, 3, 799.9, 10.00, 227.02, 2162.68, 'active'),
(85, 51, 11, 2, 21999.9, 25.00, 6156.47, 37818.33, 'active'),
(86, 59, 19, 1, 1299.9, 20.00, 159.99, 1119.91, 'active'),
(87, 67, 7, 3, 2499.9, 20.00, 822.77, 6656.93, 'active'),
(88, 75, 15, 2, 1299.9, 15.00, 232.63, 2352.17, 'active'),
(89, 82, 2, 1, 1899.9, 30.00, 186.99, 1682.91, 'active'),
(90, 90, 10, 4, 8999.9, 15.00, 1979.15, 34005.45, 'active'),
(91, 97, 17, 2, 3499.9, 20.00, 732.88, 6246.92, 'active'),
(92, 105, 5, 1, 299.9, 40.00, 15.59, 244.31, 'active'),
(93, 113, 13, 3, 2499.9, 15.00, 523.93, 6960.77, 'active'),
(94, 120, 20, 2, 1799.9, 20.00, 259.54, 3320.26, 'active'),
(95, 5, 5, 1, 16999.9, 25.00, 1018.49, 15956.41, 'returned'),
(96, 14, 14, 4, 2999.9, 10.00, 779.32, 11210.28, 'active'),
(97, 26, 6, 2, 1599.9, 20.00, 302.08, 2877.72, 'active'),
(98, 34, 14, 1, 449.9, 30.00, 27.29, 392.61, 'active'),
(99, 43, 3, 3, 199.9, 15.00, 43.85, 540.85, 'active'),
(100, 50, 10, 2, 24999.9, 20.00, 2748.89, 47230.91, 'active'),
(101, 58, 18, 1, 1499.9, 45.00, 72.75, 1382.15, 'active'),
(102, 66, 6, 3, 899.9, 10.00, 255.52, 2434.18, 'active'),
(103, 74, 14, 2, 6499.9, 15.00, 844.01, 12140.79, 'active'),
(104, 81, 1, 1, 2999.9, 30.00, 252.44, 2717.46, 'active'),
(105, 89, 9, 4, 15999.9, 10.00, 8638.60, 55351.00, 'active'),
(106, 96, 16, 2, 699.9, 20.00, 120.73, 1259.07, 'active'),
(107, 103, 3, 1, 699.9, 35.00, 49.87, 615.03, 'active'),
(108, 111, 11, 3, 249.9, 15.00, 102.86, 631.84, 'active'),
(109, 119, 19, 2, 699.9, 20.00, 172.48, 1207.32, 'active'),
(110, 6, 6, 1, 34999.9, 25.00, 3322.62, 31652.28, 'active'),
(111, 13, 13, 3, 2499.9, 10.00, 524.28, 6965.42, 'active'),
(112, 21, 1, 2, 3999.9, 20.00, 678.28, 7301.52, 'active'),
(113, 29, 9, 1, 999.9, 35.00, 130.26, 834.64, 'active'),
(114, 37, 17, 4, 549.9, 10.00, 229.91, 1959.69, 'active'),
(115, 45, 5, 2, 999.9, 20.00, 118.79, 1861.01, 'active'),
(116, 53, 13, 1, 25999.9, 25.00, 1818.24, 24156.66, 'active'),
(117, 61, 1, 3, 899.9, 15.00, 228.20, 2456.50, 'active'),
(118, 69, 9, 2, 499.9, 10.00, 133.62, 856.18, 'returned'),
(119, 76, 16, 1, 1799.9, 40.00, 153.99, 1605.91, 'active'),
(120, 83, 3, 3, 1499.9, 10.00, 336.73, 4152.97, 'active'),
(121, 91, 11, 2, 499.9, 25.00, 136.47, 838.33, 'active'),
(122, 99, 19, 1, 799.9, 20.00, 97.49, 682.41, 'active'),
(123, 107, 7, 4, 299.9, 15.00, 130.31, 1054.29, 'active'),
(124, 115, 15, 2, 899.9, 20.00, 160.18, 1619.62, 'active'),
(125, 3, 3, 1, 10999.9, 30.00, 822.74, 10147.16, 'active'),
(126, 12, 12, 3, 1399.9, 15.00, 627.71, 3556.99, 'active'),
(127, 20, 20, 2, 1999.9, 20.00, 288.54, 3691.26, 'active'),
(128, 28, 8, 1, 899.9, 40.00, 68.79, 791.11, 'active'),
(129, 36, 16, 4, 399.9, 10.00, 139.09, 1450.51, 'active'),
(130, 44, 4, 2, 149.9, 20.00, 33.58, 246.22, 'active'),
(131, 52, 12, 1, 19999.9, 25.00, 2996.24, 16978.66, 'active'),
(132, 60, 20, 3, 699.9, 10.00, 151.50, 1938.20, 'active'),
(133, 68, 8, 2, 699.9, 15.00, 110.78, 1274.02, 'active'),
(134, 76, 16, 1, 1799.9, 30.00, 154.87, 1615.03, 'active'),
(135, 84, 4, 4, 2499.9, 10.00, 1198.75, 8790.85, 'active'),
(136, 92, 12, 2, 599.9, 20.00, 176.97, 1002.83, 'active'),
(137, 100, 20, 1, 999.9, 45.00, 69.23, 885.67, 'active'),
(138, 108, 8, 3, 299.9, 15.00, 70.78, 813.92, 'active'),
(139, 116, 16, 2, 399.9, 10.00, 69.11, 720.69, 'active'),
(140, 4, 4, 1, 14999.9, 25.00, 1796.99, 13177.91, 'active'),
(141, 11, 11, 4, 1299.9, 10.00, 726.54, 4463.06, 'active'),
(142, 19, 19, 2, 3499.9, 20.00, 872.48, 6107.32, 'active'),
(143, 27, 7, 1, 2499.9, 35.00, 271.14, 2193.76, 'active'),
(144, 35, 15, 3, 499.9, 10.00, 134.07, 1355.63, 'active'),
(145, 43, 3, 2, 199.9, 25.00, 28.11, 346.69, 'active'),
(146, 51, 11, 1, 21999.9, 20.00, 3077.19, 18902.71, 'active'),
(147, 59, 19, 3, 1299.9, 20.00, 484.96, 3394.74, 'active'),
(148, 67, 7, 2, 2499.9, 15.00, 548.33, 4436.47, 'active'),
(149, 75, 15, 1, 1299.9, 30.00, 114.29, 1155.61, 'active'),
(150, 83, 3, 4, 1499.9, 15.00, 448.85, 5535.75, 'returned'),
(1, 91, 11, 1, 499.9, 10.00, 68.59, 421.31, 'active'),
(2, 98, 18, 2, 1999.9, 20.00, 198.99, 3780.81, 'active'),
(3, 105, 5, 3, 299.9, 10.00, 53.38, 836.32, 'active'),
(4, 112, 12, 1, 249.9, 40.00, 31.49, 178.41, 'active'),
(5, 120, 20, 2, 1799.9, 15.00, 259.90, 3324.90, 'active'),
(6, 2, 2, 4, 42999.9, 10.00, 17198.96, 154790.64, 'active'),
(7, 10, 10, 1, 499.9, 20.00, 26.39, 453.51, 'active'),
(8, 18, 18, 2, 6499.9, 10.00, 649.49, 12340.31, 'active'),
(9, 26, 6, 3, 1599.9, 10.00, 455.02, 4334.68, 'active'),
(10, 34, 14, 1, 449.9, 30.00, 27.29, 392.61, 'active'),
(11, 42, 2, 2, 1299.9, 20.00, 257.98, 2321.82, 'active'),
(12, 50, 10, 4, 24999.9, 10.00, 5499.43, 94490.17, 'active'),
(13, 58, 18, 1, 1499.9, 30.00, 73.50, 1396.40, 'active'),
(14, 66, 6, 3, 899.9, 15.00, 255.05, 2429.65, 'active'),
(15, 74, 14, 2, 6499.9, 20.00, 843.69, 12136.11, 'active'),
(16, 82, 2, 1, 1899.9, 25.00, 187.49, 1687.41, 'active'),
(17, 90, 10, 3, 8999.9, 15.00, 1484.16, 25500.54, 'active'),
(18, 97, 17, 2, 3499.9, 15.00, 733.40, 6251.40, 'active'),
(19, 104, 4, 1, 399.9, 45.00, 42.59, 312.31, 'active'),
(20, 111, 11, 4, 249.9, 10.00, 138.54, 851.06, 'active'),
(21, 118, 18, 2, 499.9, 20.00, 48.99, 930.81, 'active'),
(22, 7, 7, 1, 27999.9, 25.00, 3077.24, 24897.66, 'active'),
(23, 15, 15, 3, 999.9, 15.00, 268.62, 2716.08, 'active'),
(24, 23, 3, 2, 5999.9, 20.00, 898.49, 11081.31, 'returned'),
(25, 31, 11, 1, 799.9, 35.00, 107.09, 657.81, 'active'),
(26, 39, 19, 4, 479.9, 10.00, 238.70, 1670.90, 'active'),
(27, 47, 7, 2, 599.9, 25.00, 129.23, 1045.57, 'active'),
(28, 55, 15, 1, 49999.9, 20.00, 4498.19, 45481.71, 'active'),
(29, 63, 3, 3, 999.9, 10.00, 224.23, 2765.47, 'active'),
(30, 71, 11, 2, 1199.9, 20.00, 333.17, 2046.63, 'active'),
(31, 79, 19, 1, 899.9, 35.00, 108.11, 756.79, 'active'),
(32, 87, 7, 3, 999.9, 15.00, 328.32, 2656.38, 'active'),
(33, 95, 15, 2, 1299.9, 25.00, 231.73, 2343.07, 'active'),
(34, 103, 3, 1, 699.9, 20.00, 50.99, 628.91, 'active'),
(35, 110, 10, 4, 449.9, 10.00, 98.43, 1691.17, 'active'),
(36, 117, 17, 2, 1499.9, 20.00, 312.88, 2666.92, 'active'),
(37, 5, 5, 1, 16999.9, 40.00, 1017.59, 15942.31, 'active'),
(38, 13, 13, 3, 2499.9, 15.00, 523.93, 6960.77, 'active'),
(39, 21, 1, 2, 3999.9, 10.00, 679.13, 7310.67, 'active'),
(40, 29, 9, 1, 999.9, 30.00, 130.94, 838.96, 'active'),
(41, 37, 17, 4, 549.9, 10.00, 229.91, 1959.69, 'active'),
(42, 45, 5, 2, 999.9, 15.00, 119.09, 1865.71, 'active'),
(43, 53, 13, 1, 25999.9, 40.00, 1817.19, 24142.71, 'active'),
(44, 61, 1, 3, 899.9, 20.00, 227.77, 2451.93, 'active'),
(45, 69, 9, 2, 499.9, 25.00, 131.60, 843.20, 'active'),
(46, 77, 17, 1, 1599.9, 15.00, 166.41, 1418.49, 'active'),
(47, 85, 5, 3, 899.9, 10.00, 161.38, 2528.32, 'active'),
(48, 93, 13, 2, 799.9, 15.00, 110.94, 1473.86, 'active'),
(49, 101, 1, 1, 2499.9, 30.00, 209.94, 2259.96, 'active'),
(50, 109, 9, 4, 349.9, 10.00, 187.60, 1202.00, 'active'),
(51, 8, 8, 2, 18999.9, 10.00, 3039.18, 34950.62, 'delivered'),
(52, 16, 16, 1, 999.9, 20.00, 85.74, 894.16, 'shipped'),
(53, 24, 4, 3, 2799.9, 15.00, 1006.16, 7378.54, 'active'),
(54, 32, 12, 2, 1199.9, 20.00, 356.97, 2022.83, 'pending'),
(55, 40, 20, 1, 649.9, 30.00, 44.94, 574.96, 'delivered'),
(56, 48, 8, 4, 899.9, 10.00, 287.17, 3302.43, 'cancelled'),
(57, 56, 16, 2, 27999.9, 20.00, 4898.23, 51081.57, 'shipped'),
(58, 64, 4, 1, 399.9, 20.00, 45.59, 334.31, 'returned'),
(59, 72, 12, 3, 799.9, 15.00, 357.71, 2026.99, 'active'),
(60, 80, 20, 2, 3499.9, 20.00, 506.04, 6473.76, 'delivered'),
(61, 88, 8, 1, 2999.9, 40.00, 236.79, 2723.11, 'shipped'),
(62, 96, 16, 4, 699.9, 10.00, 244.09, 2545.51, 'pending'),
(63, 104, 4, 2, 399.9, 25.00, 92.98, 681.82, 'delivered'),
(64, 112, 12, 1, 249.9, 25.00, 33.74, 191.16, 'cancelled'),
(65, 120, 20, 3, 1799.9, 15.00, 390.39, 4994.31, 'active'),
(66, 7, 7, 2, 27999.9, 15.00, 6158.33, 49826.47, 'returned'),
(67, 15, 15, 1, 999.9, 30.00, 87.29, 882.61, 'delivered'),
(68, 23, 3, 4, 5999.9, 10.00, 1799.22, 22190.38, 'shipped'),
(69, 31, 11, 2, 799.9, 20.00, 221.17, 1358.63, 'pending'),
(70, 39, 19, 1, 479.9, 35.00, 55.61, 389.29, 'active'),
(71, 47, 7, 3, 599.9, 15.00, 196.32, 1588.38, 'delivered'),
(72, 55, 15, 2, 49999.9, 25.00, 8997.73, 90977.07, 'cancelled'),
(73, 63, 3, 1, 999.9, 25.00, 73.12, 901.78, 'shipped'),
(74, 71, 11, 4, 1199.9, 15.00, 669.84, 4114.76, 'returned'),
(75, 79, 19, 2, 899.9, 20.00, 222.48, 1557.32, 'active'),
(76, 87, 7, 1, 999.9, 40.00, 105.59, 854.31, 'delivered'),
(77, 95, 15, 3, 1299.9, 10.00, 350.07, 3539.63, 'pending'),
(78, 103, 3, 2, 699.9, 15.00, 103.86, 1280.94, 'shipped'),
(79, 111, 11, 1, 249.9, 30.00, 30.79, 189.11, 'delivered'),
(80, 119, 19, 3, 699.9, 20.00, 259.96, 1819.74, 'returned'),
(81, 6, 6, 2, 34999.9, 15.00, 6648.56, 63336.24, 'active'),
(82, 14, 14, 1, 2999.9, 25.00, 193.37, 2781.53, 'returned'),
(83, 22, 2, 4, 1499.9, 10.00, 598.96, 5390.64, 'delivered'),
(84, 30, 10, 2, 399.9, 20.00, 42.89, 736.91, 'shipped'),
(85, 38, 18, 1, 599.9, 35.00, 28.25, 536.65, 'pending'),
(86, 46, 6, 3, 799.9, 10.00, 227.02, 2162.68, 'active'),
(87, 54, 14, 2, 37999.9, 20.00, 4938.69, 71041.11, 'delivered'),
(88, 62, 2, 1, 1999.9, 30.00, 196.99, 1772.91, 'cancelled'),
(89, 70, 10, 4, 2199.9, 10.00, 483.43, 8306.17, 'shipped'),
(90, 78, 18, 2, 2999.9, 20.00, 298.99, 5680.81, 'returned'),
(91, 86, 6, 1, 1199.9, 30.00, 111.14, 1058.76, 'active'),
(92, 94, 14, 3, 999.9, 15.00, 194.01, 2790.69, 'delivered'),
(93, 102, 2, 2, 499.9, 25.00, 97.48, 877.32, 'pending'),
(94, 110, 10, 1, 449.9, 20.00, 23.64, 406.26, 'shipped'),
(95, 118, 18, 3, 499.9, 10.00, 74.49, 1415.21, 'delivered'),
(96, 5, 5, 2, 16999.9, 15.00, 2039.09, 31945.71, 'cancelled'),
(97, 13, 13, 1, 2499.9, 30.00, 172.89, 2297.01, 'active'),
(98, 21, 1, 4, 3999.9, 10.00, 1359.12, 14630.48, 'returned'),
(99, 29, 9, 2, 999.9, 20.00, 267.27, 1712.53, 'delivered'),
(100, 37, 17, 1, 549.9, 40.00, 53.54, 456.36, 'shipped'),
(101, 45, 5, 3, 999.9, 15.00, 179.08, 2805.62, 'pending'),
(102, 53, 13, 2, 25999.9, 20.00, 3638.59, 48341.21, 'active'),
(103, 61, 1, 1, 899.9, 35.00, 73.52, 791.38, 'delivered'),
(104, 69, 9, 4, 499.9, 10.00, 268.60, 1721.00, 'cancelled'),
(105, 77, 17, 2, 1599.9, 20.00, 333.88, 2845.92, 'shipped'),
(106, 85, 5, 1, 899.9, 25.00, 52.49, 822.41, 'returned'),
(107, 93, 13, 3, 799.9, 15.00, 166.93, 2217.77, 'active'),
(108, 101, 1, 2, 2499.9, 20.00, 423.28, 4556.52, 'delivered'),
(109, 109, 9, 1, 349.9, 45.00, 41.16, 263.74, 'pending'),
(110, 117, 17, 3, 1499.9, 10.00, 471.42, 4018.28, 'shipped'),
(111, 4, 4, 2, 14999.9, 15.00, 3598.18, 26386.62, 'delivered'),
(112, 12, 12, 1, 1399.9, 30.00, 205.49, 1164.41, 'returned'),
(113, 20, 20, 4, 1999.9, 15.00, 578.88, 7405.72, 'active'),
(114, 28, 8, 2, 899.9, 20.00, 142.38, 1637.42, 'returned'),
(115, 36, 16, 1, 399.9, 40.00, 31.49, 328.41, 'delivered'),
(116, 44, 4, 3, 149.9, 15.00, 52.16, 382.54, 'shipped'),
(117, 52, 12, 2, 19999.9, 20.00, 5996.97, 33982.83, 'pending'),
(118, 60, 20, 1, 699.9, 30.00, 48.57, 621.33, 'active'),
(119, 68, 8, 4, 699.9, 10.00, 223.17, 2566.43, 'delivered'),
(120, 76, 16, 2, 1799.9, 25.00, 312.80, 3262.00, 'cancelled'),
(121, 84, 4, 1, 2499.9, 25.00, 296.99, 2177.91, 'shipped'),
(122, 92, 12, 3, 599.9, 10.00, 268.46, 1521.24, 'returned'),
(123, 100, 20, 2, 999.9, 20.00, 143.54, 1836.26, 'active'),
(124, 108, 8, 1, 299.9, 40.00, 20.79, 239.11, 'delivered'),
(125, 116, 16, 3, 399.9, 10.00, 104.10, 1085.60, 'pending'),
(126, 3, 3, 2, 10999.9, 10.00, 1649.24, 20340.56, 'shipped'),
(127, 11, 11, 1, 1299.9, 30.00, 177.79, 1092.11, 'cancelled'),
(128, 19, 19, 4, 3499.9, 10.00, 1748.70, 12240.90, 'active'),
(129, 27, 7, 2, 2499.9, 20.00, 547.78, 4432.02, 'delivered'),
(130, 35, 15, 1, 499.9, 35.00, 41.84, 423.06, 'returned'),
(131, 43, 3, 3, 199.9, 20.00, 43.48, 536.22, 'shipped'),
(132, 51, 11, 2, 21999.9, 15.00, 6157.87, 37826.93, 'pending'),
(133, 59, 19, 1, 1299.9, 35.00, 158.11, 1106.79, 'delivered'),
(134, 67, 7, 4, 2499.9, 10.00, 1098.86, 8890.74, 'active'),
(135, 75, 15, 2, 1299.9, 20.00, 232.18, 2347.62, 'cancelled'),
(136, 83, 3, 1, 1499.9, 45.00, 109.12, 1345.78, 'returned'),
(137, 91, 11, 3, 499.9, 10.00, 208.56, 1281.14, 'returned'),
(138, 99, 19, 2, 799.9, 15.00, 198.10, 1386.70, 'delivered'),
(139, 107, 7, 1, 299.9, 30.00, 29.69, 240.21, 'pending'),
(140, 115, 15, 3, 899.9, 15.00, 241.62, 2443.08, 'active'),
(141, 2, 2, 2, 42999.9, 20.00, 8597.98, 77381.82, 'delivered'),
(142, 10, 10, 1, 499.9, 35.00, 25.57, 439.33, 'cancelled'),
(143, 18, 18, 4, 6499.9, 10.00, 1299.48, 24690.12, 'shipped'),
(144, 26, 6, 2, 1599.9, 20.00, 302.08, 2877.72, 'returned'),
(145, 34, 14, 1, 449.9, 25.00, 27.62, 397.28, 'active'),
(146, 42, 2, 3, 1299.9, 15.00, 388.47, 3496.23, 'delivered'),
(147, 50, 10, 2, 24999.9, 20.00, 2748.89, 47230.91, 'pending'),
(148, 58, 18, 1, 1499.9, 40.00, 73.00, 1386.90, 'shipped'),
(149, 66, 6, 3, 899.9, 20.00, 254.57, 2425.13, 'cancelled'),
(150, 74, 14, 2, 6499.9, 15.00, 844.01, 12140.79, 'delivered'),
(1, 82, 2, 1, 1899.9, 30.00, 186.99, 1682.91, 'returned'),
(2, 90, 10, 4, 8999.9, 15.00, 1979.15, 34005.45, 'active'),
(3, 98, 18, 2, 1999.9, 20.00, 198.99, 3780.81, 'shipped'),
(4, 106, 6, 1, 299.9, 40.00, 24.69, 235.21, 'delivered'),
(5, 114, 14, 3, 599.9, 15.00, 116.01, 1668.69, 'pending'),
(6, 1, 1, 2, 8999.9, 15.00, 1528.71, 16456.09, 'cancelled'),
(7, 9, 9, 1, 499.9, 30.00, 63.44, 406.46, 'active'),
(8, 17, 17, 4, 8999.9, 10.00, 3778.91, 32210.69, 'returned'),
(9, 25, 5, 2, 699.9, 25.00, 82.49, 1292.31, 'delivered'),
(10, 33, 13, 1, 349.9, 20.00, 23.09, 306.81, 'shipped'),
(11, 41, 1, 3, 249.9, 10.00, 62.87, 676.83, 'pending'),
(12, 49, 9, 2, 22999.9, 20.00, 6207.27, 39772.53, 'delivered'),
(13, 57, 17, 1, 1799.9, 35.00, 185.31, 1579.59, 'cancelled'),
(14, 65, 5, 4, 1899.9, 10.00, 455.38, 7134.22, 'active'),
(15, 73, 13, 2, 3999.9, 20.00, 558.59, 7421.21, 'shipped'),
(16, 81, 1, 1, 2999.9, 25.00, 252.87, 2722.03, 'returned'),
(17, 89, 9, 3, 15999.9, 15.00, 6477.93, 41506.77, 'delivered'),
(18, 97, 17, 2, 3499.9, 20.00, 732.88, 6246.92, 'returned'),
(19, 105, 5, 1, 299.9, 45.00, 15.29, 239.61, 'active'),
(20, 113, 13, 3, 2499.9, 10.00, 524.28, 6965.42, 'cancelled'),
(21, 120, 20, 2, 1799.9, 15.00, 259.90, 3324.90, 'delivered'),
(22, 6, 6, 1, 34999.9, 30.00, 3322.14, 31647.76, 'shipped'),
(23, 14, 14, 4, 2999.9, 15.00, 779.00, 11205.60, 'returned'),
(24, 22, 2, 2, 1499.9, 20.00, 297.98, 2681.82, 'active'),
(25, 30, 10, 1, 399.9, 40.00, 19.79, 340.11, 'delivered'),
(26, 38, 18, 3, 599.9, 15.00, 89.24, 1695.46, 'pending'),
(27, 46, 6, 2, 799.9, 20.00, 150.08, 1429.72, 'cancelled'),
(28, 54, 14, 1, 37999.9, 30.00, 2468.04, 35501.86, 'shipped'),
(29, 62, 2, 4, 1999.9, 10.00, 798.96, 7190.64, 'delivered'),
(30, 70, 10, 2, 2199.9, 25.00, 240.61, 4134.19, 'returned'),
(31, 78, 18, 1, 2999.9, 25.00, 148.75, 2826.15, 'active'),
(32, 86, 6, 3, 1199.9, 10.00, 341.02, 3248.68, 'shipped'),
(33, 94, 14, 2, 999.9, 20.00, 128.69, 1851.11, 'delivered'),
(34, 102, 2, 1, 499.9, 40.00, 45.99, 413.91, 'cancelled'),
(35, 110, 10, 3, 449.9, 10.00, 73.68, 1266.02, 'pending'),
(36, 118, 18, 2, 499.9, 10.00, 49.49, 940.31, 'active'),
(37, 5, 5, 1, 16999.9, 30.00, 1018.19, 15951.71, 'returned'),
(38, 13, 13, 4, 2499.9, 10.00, 699.27, 9290.33, 'delivered'),
(39, 21, 1, 2, 3999.9, 20.00, 678.28, 7301.52, 'shipped'),
(40, 29, 9, 1, 999.9, 35.00, 130.26, 834.64, 'cancelled'),
(41, 37, 17, 3, 549.9, 20.00, 171.12, 1458.58, 'active'),
(42, 45, 5, 2, 999.9, 15.00, 119.09, 1865.71, 'delivered'),
(43, 53, 13, 1, 25999.9, 35.00, 1817.54, 24147.36, 'pending'),
(44, 61, 1, 4, 899.9, 10.00, 305.12, 3284.48, 'shipped'),
(45, 69, 9, 2, 499.9, 20.00, 132.27, 847.53, 'returned'),
(46, 77, 17, 1, 1599.9, 45.00, 163.26, 1391.64, 'delivered'),
(47, 85, 5, 3, 899.9, 10.00, 161.38, 2528.32, 'cancelled'),
(48, 93, 13, 2, 799.9, 15.00, 110.94, 1473.86, 'active'),
(49, 101, 1, 1, 2499.9, 30.00, 209.94, 2259.96, 'shipped'),
(50, 109, 9, 3, 349.9, 15.00, 139.68, 895.02, 'returned'),
(51, 117, 17, 2, 1499.9, 20.00, 312.88, 2666.92, 'active'),
(52, 4, 4, 1, 14999.9, 25.00, 1796.99, 13177.91, 'delivered'),
(53, 12, 12, 3, 1399.9, 15.00, 627.71, 3556.99, 'shipped'),
(54, 20, 20, 2, 1999.9, 20.00, 288.54, 3691.26, 'pending'),
(55, 28, 8, 1, 899.9, 35.00, 69.19, 795.71, 'returned'),
(56, 36, 16, 4, 399.9, 10.00, 139.09, 1450.51, 'cancelled'),
(57, 44, 4, 2, 149.9, 20.00, 33.58, 246.22, 'delivered'),
(58, 52, 12, 1, 19999.9, 30.00, 2995.49, 16974.41, 'active'),
(59, 60, 20, 3, 699.9, 10.00, 151.50, 1938.20, 'shipped'),
(60, 68, 8, 2, 699.9, 15.00, 110.78, 1274.02, 'pending'),
(61, 76, 16, 1, 1799.9, 40.00, 153.99, 1605.91, 'delivered'),
(62, 84, 4, 4, 2499.9, 10.00, 1198.75, 8790.85, 'returned'),
(63, 92, 12, 2, 599.9, 20.00, 176.97, 1002.83, 'active'),
(64, 100, 20, 1, 999.9, 25.00, 70.68, 904.22, 'cancelled'),
(65, 108, 8, 3, 299.9, 15.00, 70.78, 813.92, 'shipped'),
(66, 116, 16, 2, 399.9, 20.00, 68.23, 711.57, 'delivered'),
(67, 3, 3, 1, 10999.9, 30.00, 822.74, 10147.16, 'pending'),
(68, 11, 11, 4, 1299.9, 10.00, 726.54, 4463.06, 'active'),
(69, 19, 19, 2, 3499.9, 25.00, 871.85, 6102.95, 'returned'),
(70, 27, 7, 1, 2499.9, 20.00, 272.79, 2207.11, 'delivered'),
(71, 35, 15, 3, 499.9, 10.00, 134.07, 1355.63, 'cancelled'),
(72, 43, 3, 2, 199.9, 20.00, 28.49, 351.31, 'shipped'),
(73, 51, 11, 1, 21999.9, 45.00, 3073.69, 18881.21, 'active'),
(74, 59, 19, 3, 1299.9, 10.00, 486.21, 3403.49, 'returned'),
(75, 67, 7, 2, 2499.9, 10.00, 548.88, 4440.92, 'delivered'),
(76, 75, 15, 1, 1299.9, 30.00, 114.29, 1155.61, 'returned'),
(77, 83, 3, 4, 1499.9, 15.00, 448.85, 5535.75, 'shipped'),
(78, 91, 11, 2, 499.9, 20.00, 137.17, 842.63, 'cancelled'),
(79, 99, 19, 1, 799.9, 40.00, 94.99, 664.91, 'active'),
(80, 107, 7, 3, 299.9, 15.00, 97.32, 787.38, 'delivered'),
(81, 115, 15, 2, 899.9, 20.00, 160.18, 1619.62, 'pending'),
(82, 2, 2, 1, 42999.9, 35.00, 4296.49, 38668.41, 'shipped'),
(83, 10, 10, 4, 499.9, 10.00, 109.43, 1880.17, 'returned'),
(84, 18, 18, 2, 6499.9, 20.00, 648.99, 12330.81, 'active'),
(85, 26, 6, 1, 1599.9, 25.00, 149.62, 1425.28, 'delivered'),
(86, 34, 14, 3, 449.9, 15.00, 86.76, 1247.94, 'cancelled'),
(87, 42, 2, 2, 1299.9, 20.00, 257.98, 2321.82, 'shipped'),
(88, 50, 10, 1, 24999.9, 40.00, 1372.79, 23587.11, 'pending'),
(89, 58, 18, 3, 1499.9, 20.00, 223.99, 4255.71, 'active'),
(90, 66, 6, 2, 899.9, 15.00, 169.56, 1615.24, 'delivered'),
(91, 74, 14, 1, 6499.9, 30.00, 420.54, 6049.36, 'returned'),
(92, 82, 2, 4, 1899.9, 10.00, 758.96, 6830.64, 'shipped'),
(93, 90, 10, 2, 8999.9, 20.00, 988.89, 16990.91, 'active'),
(94, 98, 18, 1, 1999.9, 35.00, 98.25, 1866.65, 'cancelled'),
(95, 106, 6, 3, 299.9, 15.00, 84.05, 800.65, 'delivered'),
(96, 114, 14, 2, 599.9, 20.00, 76.69, 1103.11, 'pending'),
(97, 1, 1, 1, 8999.9, 45.00, 761.17, 8193.73, 'shipped'),
(98, 9, 9, 4, 499.9, 10.00, 268.60, 1721.00, 'returned'),
(99, 17, 17, 2, 8999.9, 15.00, 1888.40, 16096.40, 'active'),
(100, 25, 5, 1, 699.9, 30.00, 40.19, 629.71, 'delivered');

INSERT INTO payments
(order_id, payment_reference, amount, payment_method, paid_at, status)
VALUES
(1, 'PAY-0001', 21749.40, 'card', '2026-08-12 10:24:00', 'paid'),
(2, 'PAY-0002', 91014.00, 'pix', '2026-08-12 11:05:00', 'paid'),
(3, 'PAY-0003', 11289.40, 'wallet', '2026-08-12 12:18:00', 'paid'),
(4, 'PAY-0004', 3494.50, 'bank_transfer', '2026-08-12 13:42:00', 'paid'),
(5, 'PAY-0005', 5754.30, 'card', '2026-08-13 09:16:00', 'paid'),
(6, 'PAY-0006', 191949.00, 'pix', '2026-08-13 10:37:00', 'paid'),
(7, 'PAY-0007', 2964.50, 'wallet', '2026-08-13 11:49:00', 'paid'),
(8, 'PAY-0008', 51419.20, 'card', '2026-08-13 14:21:00', 'paid'),
(9, 'PAY-0009', 7709.10, 'pix', '2026-08-14 09:32:00', 'paid'),
(10, 'PAY-0010', 1929.60, 'card', '2026-08-14 10:44:00', 'paid'),
(11, 'PAY-0011', 4209.30, 'bank_transfer', '2026-08-14 12:15:00', 'paid'),
(12, 'PAY-0012', 245979.10, 'pix', '2026-08-14 15:06:00', 'paid'),
(13, 'PAY-0013', 3894.70, 'card', '2026-08-15 09:27:00', 'paid'),
(14, 'PAY-0014', 94303.90, 'wallet', '2026-08-15 11:18:00', 'paid'),
(15, 'PAY-0015', 26979.30, 'pix', '2026-08-15 13:35:00', 'paid'),
(16, 'PAY-0016', 8879.60, 'card', '2026-08-15 16:12:00', 'paid'),
(17, 'PAY-0017', 78514.00, 'bank_transfer', '2026-08-16 10:08:00', 'paid'),
(18, 'PAY-0018', 14774.30, 'card', '2026-08-16 11:46:00', 'paid'),
(19, 'PAY-0019', 729.60, 'pix', '2026-08-16 14:29:00', 'paid'),
(20, 'PAY-0020', 68464.00, 'wallet', '2026-08-16 17:03:00', 'paid'),
(21, 'PAY-0021', 6349.30, 'card', '2026-08-17 09:41:00', 'paid'),
(22, 'PAY-0022', 63679.60, 'pix', '2026-08-17 10:22:00', 'paid'),
(23, 'PAY-0023', 22919.10, 'bank_transfer', '2026-08-17 12:54:00', 'paid'),
(24, 'PAY-0024', 18444.40, 'card', '2026-08-17 15:18:00', 'paid'),
(25, 'PAY-0025', 4694.40, 'pix', '2026-08-18 09:13:00', 'paid'),
(26, 'PAY-0026', 4924.00, 'wallet', '2026-08-18 11:27:00', 'paid'),
(27, 'PAY-0027', 4689.50, 'card', '2026-08-18 13:44:00', 'paid'),
(28, 'PAY-0028', 89584.30, 'pix', '2026-08-18 16:31:00', 'paid'),
(29, 'PAY-0029', 11794.00, 'bank_transfer', '2026-08-19 10:05:00', 'paid'),
(30, 'PAY-0030', 7164.40, 'card', '2026-08-19 12:48:00', 'paid'),
(31, 'PAY-0031', 25849.50, 'pix', '2026-08-19 14:16:00', 'paid'),
(32, 'PAY-0032', 7859.30, 'wallet', '2026-08-19 17:25:00', 'paid'),
(33, 'PAY-0033', 15054.20, 'card', '2026-08-20 09:52:00', 'paid'),
(34, 'PAY-0034', 2559.50, 'bank_transfer', '2026-08-20 11:36:00', 'paid'),
(35, 'PAY-0035', 3464.10, 'pix', '2026-08-20 13:17:00', 'paid'),
(36, 'PAY-0036', 5004.10, 'card', '2026-08-20 15:42:00', 'paid'),
(37, 'PAY-0037', 79894.60, 'wallet', '2026-08-21 10:14:00', 'paid'),
(38, 'PAY-0038', 19279.10, 'pix', '2026-08-21 12:08:00', 'paid'),
(39, 'PAY-0039', 17134.20, 'card', '2026-08-21 14:37:00', 'paid'),
(40, 'PAY-0040', 3514.60, 'bank_transfer', '2026-08-21 16:54:00', 'paid'),
(41, 'PAY-0041', 4639.10, 'pix', '2026-08-22 09:18:00', 'paid'),
(42, 'PAY-0042', 6004.30, 'card', '2026-08-22 11:43:00', 'paid'),
(43, 'PAY-0043', 57104.40, 'wallet', '2026-08-22 13:26:00', 'paid'),
(44, 'PAY-0044', 6759.10, 'pix', '2026-08-22 15:11:00', 'paid'),
(45, 'PAY-0045', 2989.20, 'card', '2026-08-23 10:03:00', 'paid'),
(46, 'PAY-0046', 6164.50, 'bank_transfer', '2026-08-23 12:34:00', 'paid'),
(47, 'PAY-0047', 40314.30, 'pix', '2026-08-23 14:48:00', 'paid'),
(48, 'PAY-0048', 10699.20, 'card', '2026-08-23 16:22:00', 'paid'),
(49, 'PAY-0049', 8934.50, 'wallet', '2026-08-24 09:45:00', 'paid'),
(50, 'PAY-0050', 3454.10, 'pix', '2026-08-24 11:29:00', 'paid'),
(51, 'PAY-0051', 43194.10, 'card', '2026-08-24 13:12:00', 'paid'),
(52, 'PAY-0052', 17894.60, 'bank_transfer', '2026-08-24 15:47:00', 'paid'),
(53, 'PAY-0053', 38589.20, 'pix', '2026-08-25 10:21:00', 'paid'),
(54, 'PAY-0054', 12334.20, 'wallet', '2026-08-25 12:06:00', 'paid'),
(55, 'PAY-0055', 5864.60, 'card', '2026-08-25 14:39:00', 'paid'),
(56, 'PAY-0056', 8169.00, 'pix', '2026-08-25 16:18:00', 'paid'),
(57, 'PAY-0057', 58979.20, 'bank_transfer', '2026-08-26 09:56:00', 'paid'),
(58, 'PAY-0058', 21804.60, 'card', '2026-08-26 11:24:00', 'paid'),
(59, 'PAY-0059', 7004.20, 'wallet', '2026-08-26 13:51:00', 'paid'),
(60, 'PAY-0060', 9524.20, 'pix', '2026-08-26 15:33:00', 'paid'),
(61, 'PAY-0061', 6539.50, 'card', '2026-08-27 10:11:00', 'paid'),
(62, 'PAY-0062', 27739.00, 'bank_transfer', '2026-08-27 12:45:00', 'paid'),
(63, 'PAY-0063', 3484.20, 'pix', '2026-08-27 14:27:00', 'paid'),
(64, 'PAY-0064', 19149.60, 'card', '2026-08-27 16:05:00', 'paid'),
(65, 'PAY-0065', 9079.20, 'wallet', '2026-08-28 09:37:00', 'paid'),
(66, 'PAY-0066', 61504.10, 'pix', '2026-08-28 11:18:00', 'paid'),
(67, 'PAY-0067', 12884.60, 'card', '2026-08-28 13:49:00', 'paid'),
(68, 'PAY-0068', 29789.00, 'bank_transfer', '2026-08-28 15:26:00', 'paid'),
(69, 'PAY-0069', 122569.20, 'pix', '2026-08-29 10:04:00', 'paid'),
(70, 'PAY-0070', 4854.60, 'card', '2026-08-29 12:41:00', 'paid'),
(71, 'PAY-0071', 4504.20, 'wallet', '2026-08-29 14:18:00', 'paid'),
(72, 'PAY-0072', 105144.20, 'pix', '2026-08-29 16:52:00', 'paid'),
(73, 'PAY-0073', 27954.50, 'card', '2026-08-30 09:26:00', 'paid'),
(74, 'PAY-0074', 9109.20, 'bank_transfer', '2026-08-30 11:57:00', 'paid'),
(75, 'PAY-0075', 9994.10, 'pix', '2026-08-30 13:33:00', 'paid'),
(76, 'PAY-0076', 2819.50, 'card', '2026-08-30 15:09:00', 'paid'),
(77, 'PAY-0077', 10429.20, 'wallet', '2026-08-31 10:15:00', 'paid'),
(78, 'PAY-0078', 131334.20, 'pix', '2026-08-31 12:36:00', 'paid'),
(79, 'PAY-0079', 39019.50, 'card', '2026-08-31 14:22:00', 'paid'),
(80, 'PAY-0080', 3914.30, 'bank_transfer', '2026-08-31 16:47:00', 'paid'),
(81, 'PAY-0081', 95794.10, 'pix', '2026-09-01 09:42:00', 'paid'),
(82, 'PAY-0082', 47449.50, 'card', '2026-09-01 11:14:00', 'paid'),
(83, 'PAY-0083', 8589.00, 'wallet', '2026-09-01 13:58:00', 'paid'),
(84, 'PAY-0084', 16119.30, 'pix', '2026-09-01 15:35:00', 'paid'),
(85, 'PAY-0085', 46149.50, 'card', '2026-09-02 10:08:00', 'paid'),
(86, 'PAY-0086', 5004.20, 'bank_transfer', '2026-09-02 12:29:00', 'paid'),
(87, 'PAY-0087', 86039.30, 'pix', '2026-09-02 14:46:00', 'paid'),
(88, 'PAY-0088', 29514.50, 'card', '2026-09-02 16:17:00', 'paid'),
(89, 'PAY-0089', 15199.10, 'wallet', '2026-09-03 09:51:00', 'paid'),
(90, 'PAY-0090', 43649.20, 'pix', '2026-09-03 11:38:00', 'paid'),
(91, 'PAY-0091', 14659.50, 'card', NULL, 'pending'),
(92, 'PAY-0092', 10874.10, 'pix', NULL, 'pending'),
(93, 'PAY-0093', 26484.20, 'bank_transfer', '2026-09-03 08:00:00', 'paid'),
(94, 'PAY-0094', 5929.60, 'card', NULL, 'pending'),
(95, 'PAY-0095', 19389.20, 'wallet', '2026-09-03 08:00:00', 'paid'),
(96, 'PAY-0096', 47154.10, 'card', '2026-09-03 08:00:00', 'paid'),
(97, 'PAY-0097', 14639.50, 'pix', NULL, 'failed'),
(98, 'PAY-0098', 18414.00, 'bank_transfer', NULL, 'failed'),
(99, 'PAY-0099', 20589.20, 'card', '2026-09-03 08:00:00', 'paid'),
(100, 'PAY-0100', 51119.60, 'wallet', NULL, 'failed'),
(101, 'PAY-0101', 4489.50, 'pix', '2026-09-04 10:17:00', 'paid'),
(102, 'PAY-0102', 54599.50, 'card', '2026-09-04 12:41:00', 'paid'),
(103, 'PAY-0103', 13889.60, 'bank_transfer', '2026-09-04 14:08:00', 'paid'),
(104, 'PAY-0104', 4909.40, 'pix', '2026-09-04 16:29:00', 'paid'),
(105, 'PAY-0105', 67169.40, 'card', '2026-09-05 09:34:00', 'paid'),
(106, 'PAY-0106', 2244.60, 'wallet', '2026-09-05 11:52:00', 'paid'),
(107, 'PAY-0107', 3109.50, 'pix', '2026-09-05 13:16:00', 'paid'),
(108, 'PAY-0108', 5669.50, 'card', '2026-09-05 15:43:00', 'paid'),
(109, 'PAY-0109', 1724.60, 'bank_transfer', '2026-09-06 10:06:00', 'paid'),
(110, 'PAY-0110', 39494.50, 'pix', '2026-09-06 12:35:00', 'paid'),
(111, 'PAY-0111', 37534.40, 'card', '2026-09-06 14:19:00', 'paid'),
(112, 'PAY-0112', 9374.60, 'wallet', '2026-09-06 16:47:00', 'paid'),
(113, 'PAY-0113', 8949.50, 'pix', '2026-09-07 09:28:00', 'paid'),
(114, 'PAY-0114', 4009.30, 'card', '2026-09-07 11:13:00', 'paid'),
(115, 'PAY-0115', 2379.60, 'bank_transfer', '2026-09-07 13:56:00', 'paid'),
(116, 'PAY-0116', 26379.60, 'pix', '2026-09-07 15:21:00', 'paid'),
(117, 'PAY-0117', 42724.40, 'wallet', '2026-09-08 10:04:00', 'paid'),
(118, 'PAY-0118', 1659.60, 'card', '2026-09-08 12:42:00', 'paid'),
(119, 'PAY-0119', 4599.40, 'pix', '2026-09-08 14:27:00', 'paid'),
(120, 'PAY-0120', 8014.50, 'bank_transfer', '2026-09-08 16:08:00', 'paid'),
(121, 'PAY-0121', 3489.60, 'card', '2026-09-09 09:47:00', 'paid'),
(122, 'PAY-0122', 2579.50, 'pix', '2026-09-09 11:25:00', 'paid'),
(123, 'PAY-0123', 3204.30, 'wallet', '2026-09-09 13:18:00', 'paid'),
(124, 'PAY-0124', 1969.70, 'card', '2026-09-09 15:54:00', 'paid'),
(125, 'PAY-0125', 12219.50, 'bank_transfer', '2026-09-10 10:13:00', 'paid'),
(126, 'PAY-0126', 26114.40, 'pix', '2026-09-10 12:36:00', 'paid'),
(127, 'PAY-0127', 5299.60, 'card', '2026-09-10 14:42:00', 'paid'),
(128, 'PAY-0128', 14799.50, 'wallet', '2026-09-10 16:17:00', 'paid'),
(129, 'PAY-0129', 6609.30, 'pix', '2026-09-11 09:31:00', 'paid'),
(130, 'PAY-0130', 759.60, 'card', '2026-09-11 11:49:00', 'paid'),
(131, 'PAY-0131', 20594.50, 'bank_transfer', '2026-09-11 13:27:00', 'paid'),
(132, 'PAY-0132', 46054.50, 'pix', '2026-09-11 15:38:00', 'paid'),
(133, 'PAY-0133', 2699.60, 'wallet', '2026-09-12 10:05:00', 'paid'),
(134, 'PAY-0134', 11754.40, 'card', '2026-09-12 12:24:00', 'paid'),
(135, 'PAY-0135', 12629.30, 'pix', '2026-09-12 14:51:00', 'paid'),
(136, 'PAY-0136', 2619.70, 'bank_transfer', '2026-09-12 16:33:00', 'paid'),
(137, 'PAY-0137', 2484.50, 'card', '2026-09-13 09:18:00', 'paid'),
(138, 'PAY-0138', 2509.40, 'pix', '2026-09-13 11:46:00', 'paid'),
(139, 'PAY-0139', 1099.60, 'wallet', '2026-09-13 13:39:00', 'paid'),
(140, 'PAY-0140', 17619.60, 'card', '2026-09-13 15:22:00', 'paid'),
(141, 'PAY-0141', 91229.30, 'pix', '2026-09-14 10:11:00', 'paid'),
(142, 'PAY-0142', 7454.60, 'bank_transfer', '2026-09-14 12:34:00', 'paid'),
(143, 'PAY-0143', 28504.40, 'card', '2026-09-14 14:16:00', 'paid'),
(144, 'PAY-0144', 4619.50, 'pix', '2026-09-14 16:48:00', 'paid'),
(145, 'PAY-0145', 839.60, 'wallet', '2026-09-15 09:27:00', 'paid'),
(146, 'PAY-0146', 25874.50, 'card', '2026-09-15 11:53:00', 'paid'),
(147, 'PAY-0147', 53919.40, 'bank_transfer', '2026-09-15 13:42:00', 'paid'),
(148, 'PAY-0148', 6374.70, 'pix', '2026-09-15 15:19:00', 'paid'),
(149, 'PAY-0149', 3989.50, 'card', '2026-09-16 10:08:00', 'paid'),
(150, 'PAY-0150', 18919.30, 'wallet', '2026-09-16 12:45:00', 'paid'),
(5, 'PAY-0151', 340.0, 'pix', '2026-09-16 14:12:00', 'partially_refunded'),
(18, 'PAY-0152', 520.0, 'card', '2026-09-16 15:37:00', 'refunded'),
(27, 'PAY-0153', 275.0, 'wallet', '2026-09-17 09:26:00', 'partially_refunded'),
(39, 'PAY-0154', 610.0, 'bank_transfer', '2026-09-17 11:48:00', 'refunded'),
(52, 'PAY-0155', 430.0, 'pix', '2026-09-17 13:19:00', 'partially_refunded'),
(64, 'PAY-0156', 780.0, 'card', '2026-09-17 15:44:00', 'refunded'),
(78, 'PAY-0157', 295.0, 'wallet', '2026-09-18 10:07:00', 'partially_refunded'),
(91, 'PAY-0158', 560.0, 'pix', NULL, 'pending'),
(112, 'PAY-0159', 715.0, 'card', NULL, 'pending'),
(135, 'PAY-0160', 480.0, 'bank_transfer', NULL, 'pending');

INSERT INTO shipments
(order_id, tracking_number, shipping_company, shipped_at, expected_delivery, delivered_at, status)
VALUES
(12, 'TRK-584921', 'Yurtici Kargo', '2026-08-14 10:25:00', '2026-08-17 18:00:00', '2026-08-17 15:42:00', 'delivered'),
(47, 'TRK-731604', 'Aras Kargo', '2026-08-18 14:10:00', '2026-08-21 18:00:00', NULL, 'in_transit'),
(5, 'TRK-249815', 'MNG Kargo', '2026-08-13 09:40:00', '2026-08-16 18:00:00', '2026-08-16 13:18:00', 'delivered'),
(83, 'TRK-916273', 'PTT Kargo', NULL, '2026-09-03 18:00:00', NULL, 'pending'),
(31, 'TRK-408562', 'Surat Kargo', '2026-08-20 11:35:00', '2026-08-23 18:00:00', '2026-08-23 16:05:00', 'delivered'),
(106, 'TRK-672194', 'Hepsijet', '2026-09-07 10:15:00', '2026-09-09 18:00:00', NULL, 'in_transit'),
(19, 'TRK-315847', 'Yurtici Kargo', '2026-08-16 13:20:00', '2026-08-19 18:00:00', '2026-08-19 14:37:00', 'delivered'),
(72, 'TRK-853206', 'Aras Kargo', '2026-08-29 09:55:00', '2026-09-01 18:00:00', '2026-08-29 11:55:00', 'delivered'),
(3, 'TRK-194638', 'MNG Kargo', '2026-08-12 16:20:00', '2026-08-15 18:00:00', '2026-08-15 12:49:00', 'delivered'),
(94, 'TRK-527481', 'Surat Kargo', NULL, '2026-09-08 18:00:00', NULL, 'pending'),
(56, 'TRK-768315', 'Hepsijet', '2026-08-25 12:05:00', '2026-08-27 18:00:00', '2026-08-27 16:21:00', 'delivered'),
(28, 'TRK-341729', 'PTT Kargo', '2026-08-18 10:30:00', '2026-08-22 18:00:00', NULL, 'in_transit'),
(119, 'TRK-905416', 'Yurtici Kargo', '2026-09-08 15:45:00', '2026-09-11 18:00:00', NULL, 'shipped'),
(41, 'TRK-286593', 'Aras Kargo', '2026-08-22 09:15:00', '2026-08-25 18:00:00', '2026-08-25 13:07:00', 'delivered'),
(67, 'TRK-614827', 'MNG Kargo', '2026-08-28 14:40:00', '2026-08-31 18:00:00', '2026-08-31 17:12:00', 'delivered'),
(14, 'TRK-472951', 'Surat Kargo', '2026-08-15 11:20:00', '2026-08-18 18:00:00', '2026-08-18 16:34:00', 'delivered'),
(101, 'TRK-839264', 'Hepsijet', '2026-09-05 10:45:00', '2026-09-07 18:00:00', '2026-09-07 14:19:00', 'delivered'),
(36, 'TRK-157483', 'PTT Kargo', '2026-08-21 13:50:00', '2026-08-25 18:00:00', '2026-08-21 15:50:00', 'delivered'),
(88, 'TRK-624915', 'Yurtici Kargo', '2026-09-02 16:17:00', '2026-09-05 18:00:00', '2026-09-02 18:17:00', 'delivered'),
(52, 'TRK-391758', 'Aras Kargo', '2026-08-24 09:25:00', '2026-08-27 18:00:00', '2026-08-27 11:43:00', 'delivered'),
(7, 'TRK-845216', 'MNG Kargo', '2026-08-13 15:35:00', '2026-08-16 18:00:00', '2026-08-16 15:26:00', 'delivered'),
(124, 'TRK-263749', 'Hepsijet', '2026-09-10 11:15:00', '2026-09-12 18:00:00', NULL, 'in_transit'),
(63, 'TRK-918532', 'Surat Kargo', '2026-08-27 14:05:00', '2026-08-30 18:00:00', '2026-08-30 13:52:00', 'delivered'),
(25, 'TRK-506184', 'Yurtici Kargo', '2026-08-18 08:55:00', '2026-08-21 18:00:00', '2026-08-21 17:28:00', 'delivered'),
(97, 'TRK-734625', 'PTT Kargo', NULL, '2026-09-09 18:00:00', NULL, 'pending'),
(44, 'TRK-182946', 'Aras Kargo', '2026-08-23 10:10:00', '2026-08-26 18:00:00', '2026-08-23 12:10:00', 'delivered'),
(115, 'TRK-659314', 'MNG Kargo', '2026-09-08 09:40:00', '2026-09-11 18:00:00', '2026-09-11 15:16:00', 'delivered'),
(9, 'TRK-327581', 'Hepsijet', '2026-08-14 13:15:00', '2026-08-16 18:00:00', '2026-08-16 12:02:00', 'delivered'),
(78, 'TRK-841963', 'Yurtici Kargo', '2026-08-31 16:25:00', '2026-09-03 18:00:00', '2026-08-31 18:25:00', 'delivered'),
(132, 'TRK-295714', 'Surat Kargo', '2026-09-13 11:50:00', '2026-09-16 18:00:00', '2026-09-13 13:50:00', 'delivered'),
(58, 'TRK-613482', 'PTT Kargo', '2026-08-26 12:30:00', '2026-08-30 18:00:00', '2026-08-30 16:44:00', 'delivered'),
(21, 'TRK-957316', 'Aras Kargo', '2026-08-17 10:45:00', '2026-08-20 18:00:00', '2026-08-20 14:08:00', 'delivered'),
(109, 'TRK-426875', 'MNG Kargo', '2026-09-06 14:20:00', '2026-09-09 18:00:00', NULL, 'in_transit'),
(39, 'TRK-781524', 'Hepsijet', '2026-08-21 09:05:00', '2026-08-24 18:00:00', '2026-08-24 12:37:00', 'delivered'),
(146, 'TRK-358219', 'Yurtici Kargo', NULL, '2026-09-18 18:00:00', NULL, 'pending'),
(16, 'TRK-694731', 'Surat Kargo', '2026-08-15 14:25:00', '2026-08-18 18:00:00', '2026-08-18 11:54:00', 'delivered'),
(91, 'TRK-247863', 'PTT Kargo', '2026-09-02 10:35:00', '2026-09-05 18:00:00', NULL, 'shipped'),
(34, 'TRK-815492', 'Aras Kargo', '2026-08-20 15:10:00', '2026-08-23 18:00:00', '2026-08-23 13:25:00', 'delivered'),
(69, 'TRK-531786', 'MNG Kargo', '2026-08-29 12:45:00', '2026-09-01 18:00:00', '2026-09-01 16:18:00', 'delivered'),
(127, 'TRK-964215', 'Hepsijet', '2026-09-11 09:20:00', '2026-09-13 18:00:00', NULL, 'in_transit'),
(48, 'TRK-276594', 'Yurtici Kargo', '2026-08-23 13:40:00', '2026-08-26 18:00:00', '2026-08-26 15:09:00', 'delivered'),
(82, 'TRK-713958', 'Surat Kargo', '2026-09-01 11:05:00', '2026-09-04 18:00:00', '2026-09-01 13:05:00', 'delivered'),
(6, 'TRK-459821', 'PTT Kargo', '2026-08-13 12:20:00', '2026-08-17 18:00:00', '2026-08-17 14:42:00', 'delivered'),
(137, 'TRK-824367', 'Aras Kargo', '2026-09-14 14:30:00', '2026-09-17 18:00:00', NULL, 'in_transit'),
(53, 'TRK-196742', 'MNG Kargo', NULL, '2026-08-29 18:00:00', NULL, 'pending'),
(112, 'TRK-638451', 'Hepsijet', '2026-09-07 13:25:00', '2026-09-10 18:00:00', '2026-09-10 16:32:00', 'delivered'),
(73, 'TRK-925714', 'Yurtici Kargo', '2026-08-30 10:50:00', '2026-09-02 18:00:00', '2026-09-02 13:46:00', 'delivered'),
(29, 'TRK-347618', 'Aras Kargo', '2026-08-19 16:15:00', '2026-08-22 18:00:00', '2026-08-22 17:05:00', 'delivered'),
(98, 'TRK-581263', 'Surat Kargo', '2026-09-04 09:30:00', '2026-09-07 18:00:00', NULL, 'in_transit'),
(143, 'TRK-762495', 'PTT Kargo', NULL, '2026-09-18 18:00:00', NULL, 'pending'),
(61, 'TRK-214859', 'MNG Kargo', '2026-08-27 11:40:00', '2026-08-30 18:00:00', '2026-08-30 14:21:00', 'delivered'),
(11, 'TRK-873641', 'Hepsijet', '2026-08-14 09:15:00', '2026-08-16 18:00:00', '2026-08-16 10:37:00', 'delivered'),
(126, 'TRK-435927', 'Yurtici Kargo', '2026-09-10 15:05:00', '2026-09-13 18:00:00', '2026-09-10 17:05:00', 'delivered'),
(42, 'TRK-698314', 'Aras Kargo', '2026-08-22 16:40:00', '2026-08-25 18:00:00', '2026-08-25 16:52:00', 'delivered'),
(85, 'TRK-352761', 'Surat Kargo', '2026-09-02 12:10:00', '2026-09-05 18:00:00', NULL, 'shipped'),
(18, 'TRK-947526', 'PTT Kargo', '2026-08-16 11:30:00', '2026-08-20 18:00:00', '2026-08-20 15:47:00', 'delivered'),
(104, 'TRK-528639', 'MNG Kargo', '2026-09-06 09:45:00', '2026-09-09 18:00:00', '2026-09-09 17:03:00', 'delivered'),
(57, 'TRK-163895', 'Hepsijet', '2026-08-25 14:55:00', '2026-08-28 18:00:00', '2026-08-25 16:55:00', 'delivered'),
(134, 'TRK-719428', 'Yurtici Kargo', '2026-09-13 13:10:00', '2026-09-16 18:00:00', '2026-09-13 15:10:00', 'delivered'),
(76, 'TRK-286147', 'Aras Kargo', NULL, '2026-09-04 18:00:00', NULL, 'pending'),
(23, 'TRK-654982', 'Surat Kargo', '2026-08-17 15:20:00', '2026-08-20 18:00:00', '2026-08-20 12:15:00', 'delivered'),
(117, 'TRK-391624', 'PTT Kargo', '2026-09-08 12:40:00', '2026-09-11 18:00:00', '2026-09-08 14:40:00', 'delivered'),
(65, 'TRK-825713', 'MNG Kargo', '2026-08-28 10:25:00', '2026-08-31 18:00:00', '2026-08-31 13:38:00', 'delivered'),
(8, 'TRK-479351', 'Yurtici Kargo', '2026-08-13 16:05:00', '2026-08-16 18:00:00', '2026-08-16 16:21:00', 'delivered'),
(145, 'TRK-936284', 'Hepsijet', NULL, '2026-09-19 18:00:00', NULL, 'pending'),
(35, 'TRK-572816', 'Aras Kargo', '2026-08-20 09:50:00', '2026-08-23 18:00:00', '2026-08-23 11:29:00', 'delivered'),
(93, 'TRK-318465', 'Surat Kargo', '2026-09-03 14:15:00', '2026-09-06 18:00:00', '2026-09-03 16:15:00', 'delivered'),
(122, 'TRK-741953', 'MNG Kargo', '2026-09-09 10:30:00', '2026-09-12 18:00:00', NULL, 'shipped'),
(27, 'TRK-265817', 'PTT Kargo', '2026-08-18 13:35:00', '2026-08-21 18:00:00', '2026-08-21 15:12:00', 'delivered'),
(49, 'TRK-894632', 'Hepsijet', '2026-08-24 16:20:00', '2026-08-27 18:00:00', '2026-08-27 12:46:00', 'delivered'),
(108, 'TRK-427159', 'Yurtici Kargo', '2026-09-06 11:55:00', '2026-09-09 18:00:00', '2026-09-06 13:55:00', 'delivered'),
(15, 'TRK-681534', 'Aras Kargo', '2026-08-15 09:35:00', '2026-08-18 18:00:00', '2026-08-18 14:27:00', 'delivered'),
(71, 'TRK-253978', 'MNG Kargo', NULL, '2026-09-02 18:00:00', NULL, 'pending'),
(139, 'TRK-516824', 'Surat Kargo', '2026-09-14 10:05:00', '2026-09-17 18:00:00', NULL, 'shipped'),
(32, 'TRK-749315', 'PTT Kargo', '2026-08-20 12:15:00', '2026-08-24 18:00:00', '2026-08-24 17:41:00', 'delivered'),
(87, 'TRK-365291', 'Hepsijet', '2026-09-02 15:30:00', '2026-09-05 18:00:00', '2026-09-05 14:18:00', 'delivered'),
(54, 'TRK-918463', 'Yurtici Kargo', '2026-08-25 10:40:00', '2026-08-28 18:00:00', '2026-08-25 12:40:00', 'delivered'),
(120, 'TRK-274856', 'Aras Kargo', '2026-09-09 14:50:00', '2026-09-12 18:00:00', '2026-09-09 16:50:00', 'delivered'),
(46, 'TRK-631927', 'MNG Kargo', '2026-08-23 08:45:00', '2026-08-26 18:00:00', '2026-08-26 13:57:00', 'delivered'),
(100, 'TRK-485216', 'Surat Kargo', NULL, '2026-09-10 18:00:00', NULL, 'pending'),
(24, 'TRK-753849', 'PTT Kargo', '2026-08-18 11:10:00', '2026-08-21 18:00:00', '2026-08-21 12:33:00', 'delivered'),
(136, 'TRK-196528', 'Hepsijet', '2026-09-13 09:25:00', '2026-09-16 18:00:00', '2026-09-13 11:25:00', 'delivered'),
(62, 'TRK-842617', 'Yurtici Kargo', '2026-08-27 15:15:00', '2026-08-30 18:00:00', '2026-08-30 15:49:00', 'delivered'),
(89, 'TRK-527936', 'Aras Kargo', '2026-09-03 10:20:00', '2026-09-06 18:00:00', NULL, 'shipped'),
(130, 'TRK-314785', 'MNG Kargo', NULL, '2026-09-15 18:00:00', NULL, 'pending'),
(38, 'TRK-679421', 'Surat Kargo', '2026-08-21 14:35:00', '2026-08-24 18:00:00', '2026-08-24 12:21:00', 'delivered'),
(114, 'TRK-925368', 'PTT Kargo', '2026-09-07 11:45:00', '2026-09-10 18:00:00', '2026-09-07 13:45:00', 'delivered'),
(68, 'TRK-451792', 'Hepsijet', '2026-08-28 13:25:00', '2026-08-31 18:00:00', '2026-08-31 15:36:00', 'delivered'),
(102, 'TRK-738514', 'Yurtici Kargo', '2026-09-05 16:10:00', '2026-09-08 18:00:00', '2026-09-05 18:10:00', 'delivered'),
(59, 'TRK-286431', 'Aras Kargo', '2026-08-26 09:20:00', '2026-08-29 18:00:00', '2026-08-29 14:43:00', 'delivered'),
(90, 'TRK-614359', 'MNG Kargo', '2026-09-03 11:38:00', '2026-09-07 18:00:00', '2026-09-03 13:38:00', 'delivered'),
(116, 'TRK-857214', 'Surat Kargo', '2026-09-08 16:25:00', '2026-09-11 18:00:00', NULL, 'in_transit'),
(4, 'TRK-329681', 'PTT Kargo', '2026-08-12 11:50:00', '2026-08-15 18:00:00', '2026-08-15 16:08:00', 'delivered'),
(79, 'TRK-742915', 'Hepsijet', '2026-09-01 13:35:00', '2026-09-04 18:00:00', '2026-09-04 15:27:00', 'delivered'),
(141, 'TRK-518763', 'Yurtici Kargo', '2026-09-14 10:11:00', '2026-09-18 18:00:00', '2026-09-14 12:11:00', 'delivered'),
(55, 'TRK-963174', 'Aras Kargo', '2026-08-25 08:50:00', '2026-08-28 18:00:00', '2026-08-28 17:14:00', 'delivered'),
(128, 'TRK-275418', 'MNG Kargo', '2026-09-11 15:40:00', '2026-09-14 18:00:00', '2026-09-11 17:40:00', 'delivered'),
(22, 'TRK-631485', 'Surat Kargo', '2026-08-17 12:55:00', '2026-08-20 18:00:00', '2026-08-20 16:41:00', 'delivered'),
(103, 'TRK-849276', 'PTT Kargo', '2026-09-05 09:10:00', '2026-09-08 18:00:00', NULL, 'shipped'),
(70, 'TRK-394618', 'Hepsijet', '2026-08-29 15:05:00', '2026-09-01 18:00:00', '2026-09-01 12:58:00', 'delivered'),
(45, 'TRK-716325', 'Yurtici Kargo', '2026-08-23 15:45:00', '2026-08-26 18:00:00', '2026-08-26 16:12:00', 'delivered'),
(131, 'TRK-582947', 'Aras Kargo', '2026-09-12 10:35:00', '2026-09-15 18:00:00', NULL, 'in_transit'),
(10, 'TRK-248531', 'MNG Kargo', '2026-08-14 08:40:00', '2026-08-17 18:00:00', '2026-08-17 13:11:00', 'delivered'),
(84, 'TRK-935714', 'PTT Kargo', '2026-09-01 15:35:00', '2026-09-06 18:00:00', '2026-09-01 17:35:00', 'delivered'),
(118, 'TRK-461829', 'Surat Kargo', '2026-09-08 14:05:00', '2026-09-11 18:00:00', '2026-09-08 16:05:00', 'delivered'),
(33, 'TRK-792415', 'Hepsijet', '2026-08-20 14:50:00', '2026-08-23 18:00:00', '2026-08-23 14:32:00', 'delivered'),
(107, 'TRK-315968', 'Yurtici Kargo', '2026-09-06 12:35:00', '2026-09-09 18:00:00', NULL, 'in_transit'),
(74, 'TRK-648213', 'Aras Kargo', '2026-08-30 09:45:00', '2026-09-02 18:00:00', '2026-09-02 17:03:00', 'delivered'),
(96, 'TRK-527814', 'MNG Kargo', '2026-09-03 08:00:00', '2026-09-08 18:00:00', '2026-09-03 10:00:00', 'delivered'),
(121, 'TRK-861495', 'PTT Kargo', '2026-09-09 13:20:00', '2026-09-12 18:00:00', NULL, 'in_transit'),
(30, 'TRK-439721', 'Surat Kargo', '2026-08-19 10:05:00', '2026-08-22 18:00:00', '2026-08-22 13:49:00', 'delivered'),
(138, 'TRK-715482', 'Hepsijet', '2026-09-14 12:15:00', '2026-09-17 18:00:00', '2026-09-14 14:15:00', 'delivered'),
(51, 'TRK-286739', 'Yurtici Kargo', '2026-08-24 11:35:00', '2026-08-27 18:00:00', '2026-08-27 15:22:00', 'delivered'),
(110, 'TRK-954126', 'Aras Kargo', '2026-09-06 16:45:00', '2026-09-09 18:00:00', '2026-09-06 18:45:00', 'delivered'),
(75, 'TRK-618534', 'MNG Kargo', '2026-08-30 13:33:00', '2026-09-05 18:00:00', '2026-08-30 15:33:00', 'delivered');

INSERT INTO returns
(order_item_id, quantity, reason, requested_at, approved_at, completed_at, status)
VALUES
(4, 1, 'Wrong size', '2026-08-12 13:18:00', '2026-08-13 09:13:00', '2026-08-17 16:38:00', 'completed'),
(9, 1, 'Product arrived damaged', '2026-08-13 15:21:00', '2026-08-14 10:06:00', NULL, 'approved'),
(17, 1, 'Item was different from the description', '2026-08-15 17:12:00', NULL, NULL, 'requested'),
(23, 1, 'Wrong product received', '2026-08-17 11:22:00', '2026-08-18 02:52:00', '2026-08-22 07:37:00', 'completed'),
(31, 1, 'Product stopped working', '2026-08-19 13:48:00', '2026-08-20 12:23:00', NULL, 'approved'),
(38, 1, 'Color was not as expected', '2026-08-21 11:14:00', NULL, NULL, 'requested'),
(45, 1, 'Damaged during delivery', '2026-08-22 16:11:00', '2026-08-23 15:21:00', '2026-08-27 23:26:00', 'completed'),
(52, 4, 'Missing parts', '2026-08-24 14:40:00', '2026-08-25 10:05:00', NULL, 'approved'),
(61, 1, 'Wrong size', '2026-08-26 17:25:00', NULL, NULL, 'requested'),
(68, 2, 'Product quality was poor', '2026-08-28 14:49:00', NULL, NULL, 'rejected'),
(74, 1, 'Item arrived damaged', '2026-08-30 15:35:00', '2026-08-31 09:50:00', '2026-09-04 13:20:00', 'completed'),
(82, 2, 'Wrong item received', '2026-09-01 11:45:00', '2026-09-02 14:15:00', NULL, 'approved'),
(89, 1, 'Product does not work', '2026-09-03 19:05:00', NULL, NULL, 'requested'),
(96, 1, 'Item was damaged', '2026-09-05 13:30:00', '2026-09-06 10:20:00', '2026-09-10 15:45:00', 'completed'),
(103, 1, 'Wrong color', '2026-09-07 16:15:00', '2026-09-08 11:35:00', NULL, 'approved'),
(111, 1, 'Size was too small', '2026-09-09 10:40:00', NULL, NULL, 'requested'),
(119, 2, 'Missing accessories', '2026-09-11 18:25:00', '2026-09-12 09:30:00', '2026-09-16 16:10:00', 'completed'),
(127, 1, 'Product did not match the listing', '2026-09-13 14:50:00', NULL, NULL, 'rejected'),
(135, 1, 'Damaged packaging and product', '2026-09-15 12:20:00', '2026-09-16 10:45:00', NULL, 'approved'),
(143, 1, 'Wrong model received', '2026-09-17 17:40:00', NULL, NULL, 'requested'),
(151, 1, 'Product stopped working', '2026-09-19 11:15:00', '2026-09-20 09:40:00', '2026-09-24 14:30:00', 'completed'),
(159, 1, 'Wrong size', '2026-09-20 15:25:00', '2026-09-21 10:10:00', NULL, 'approved'),
(167, 1, 'Product arrived scratched', '2026-09-21 18:05:00', NULL, NULL, 'requested'),
(175, 2, 'Different product received', '2026-09-22 13:45:00', '2026-09-23 11:25:00', '2026-09-27 15:50:00', 'completed'),
(183, 3, 'Item was not working properly', '2026-09-23 16:30:00', NULL, NULL, 'requested'),
(191, 1, 'Wrong color received', '2026-09-24 10:55:00', '2026-09-25 09:15:00', NULL, 'approved'),
(199, 2, 'Damaged on arrival', '2026-09-25 14:20:00', NULL, NULL, 'rejected'),
(207, 4, 'Missing component', '2026-09-26 17:10:00', NULL, NULL, 'requested'),
(215, 1, 'Wrong item received', '2026-09-27 11:35:00', '2026-09-28 09:50:00', NULL, 'approved'),
(223, 2, 'Product was not as described', '2026-09-28 16:45:00', '2026-09-28 16:45:00', '2026-09-28 18:45:00', 'completed'),
(231, 2, 'Product arrived damaged', '2026-09-29 10:20:00', '2026-09-29 11:20:00', '2026-09-29 12:20:00', 'completed'),
(239, 1, 'Wrong size received', '2026-09-25 17:04:00', '2026-09-26 13:39:00', NULL, 'approved'),
(247, 2, 'Product quality was poor', '2026-09-25 17:21:00', NULL, NULL, 'requested'),
(255, 1, 'Wrong product received', '2026-09-25 17:38:00', NULL, NULL, 'rejected'),
(263, 1, 'Missing accessories', '2026-09-25 17:55:00', '2026-09-26 12:45:00', '2026-09-26 12:45:00', 'completed'),
(271, 2, 'Item was different from the description', '2026-09-25 18:12:00', NULL, NULL, 'requested'),
(279, 1, 'Product stopped working', '2026-09-25 18:29:00', '2026-09-26 16:49:00', NULL, 'approved'),
(287, 1, 'Damaged during delivery', '2026-09-25 18:46:00', '2026-09-26 12:31:00', '2026-09-26 12:31:00', 'completed'),
(295, 2, 'Wrong color received', '2026-09-25 19:03:00', NULL, NULL, 'rejected'),
(303, 3, 'Missing parts', '2026-09-25 19:20:00', '2026-09-26 20:05:00', '2026-09-26 20:05:00', 'completed'),
(311, 1, 'Product did not match the listing', '2026-09-25 19:37:00', NULL, NULL, 'requested'),
(319, 2, 'Item arrived scratched', '2026-09-25 19:54:00', '2026-09-26 12:49:00', '2026-09-26 12:49:00', 'completed'),
(327, 1, 'Wrong model received', '2026-09-25 20:11:00', '2026-09-26 18:46:00', NULL, 'approved'),
(335, 1, 'Product was not working properly', '2026-09-25 20:28:00', NULL, NULL, 'requested'),
(343, 2, 'Damaged packaging and product', '2026-09-25 20:45:00', NULL, NULL, 'rejected'),
(351, 3, 'Wrong item received', '2026-09-25 21:02:00', '2026-09-26 19:47:00', '2026-09-26 19:47:00', 'completed'),
(359, 1, 'Size was too small', '2026-09-25 21:19:00', NULL, NULL, 'requested'),
(367, 2, 'Missing component', '2026-09-25 21:36:00', '2026-09-26 18:46:00', NULL, 'approved'),
(375, 2, 'Product arrived broken', '2026-09-25 21:53:00', '2026-09-26 13:13:00', '2026-09-26 13:13:00', 'completed'),
(383, 1, 'Product was not as described', '2026-09-25 22:10:00', NULL, NULL, 'requested');

INSERT INTO refunds
(return_id, payment_id, amount, refunded_at, status)
VALUES
(1, 3, 120.00, '2026-08-17 16:38:00', 'completed'),
(2, 8, 85.50, NULL, 'pending'),
(3, 16, 210.00, NULL, 'pending'),
(4, 22, 150.00, '2026-08-22 14:30:00', 'completed'),
(5, 30, 95.75, NULL, 'approved'),
(6, 37, 320.00, NULL, 'pending'),
(7, 44, 175.00, '2026-08-28 11:45:00', 'completed'),
(8, 51, 450.00, NULL, 'approved'),
(9, 60, 65.00, NULL, 'pending'),
(10, 67, 230.50, NULL, 'rejected'),
(11, 73, 140.00, '2026-09-05 09:30:00', 'completed'),
(12, 81, 275.00, NULL, 'approved'),
(13, 88, 110.00, NULL, 'pending'),
(14, 95, 190.00, '2026-09-11 15:20:00', 'completed'),
(15, 102, 75.50, NULL, 'approved'),
(16, 110, 260.00, NULL, 'pending'),
(17, 118, 340.00, '2026-09-17 12:10:00', 'completed'),
(18, 126, 125.00, NULL, 'rejected'),
(19, 134, 215.75, NULL, 'approved'),
(20, 142, 180.00, NULL, 'pending'),
(21, 150, 300.00, '2026-09-25 10:40:00', 'completed'),
(22, 8, 155.50, NULL, 'approved'),
(23, 16, 90.00, NULL, 'pending'),
(24, 24, 420.00, '2026-09-28 14:15:00', 'completed'),
(25, 32, 250.00, NULL, 'pending'),
(26, 40, 135.00, NULL, 'approved'),
(27, 48, 380.00, NULL, 'rejected'),
(28, 56, 195.50, NULL, 'pending'),
(29, 64, 224.90, NULL, 'approved'),
(30, 72, 160.00, '2026-09-28 19:00:00', 'completed'),
(31, 80, 285.00, '2026-09-29 12:35:00', 'completed'),
(32, 88, 105.50, NULL, 'pending'),
(33, 96, 350.00, NULL, 'approved'),
(34, 104, 145.00, NULL, 'rejected'),
(35, 112, 470.00, '2026-09-26 13:00:00', 'completed'),
(36, 120, 200.00, NULL, 'pending'),
(37, 128, 165.75, NULL, 'approved'),
(38, 136, 310.00, '2026-09-26 12:46:00', 'completed'),
(39, 144, 130.00, NULL, 'rejected'),
(40, 2, 240.00, '2026-09-26 20:20:00', 'completed');

INSERT INTO reviews
(customer_id, product_id, order_item_id, rating, comment, created_at, status)
VALUES
(1, 1, 1, 5, 'Excellent product and very good quality', '2026-08-13 10:24:00', 'active'),
(3, 18, 4, 4, 'Good product and fast delivery', '2026-08-16 12:49:00', 'active'),
(6, 9, 7, 3, 'Product is acceptable for the price', '2026-08-18 14:42:00', 'active'),
(9, 35, 10, 5, 'Amazing quality and exactly as described', '2026-08-17 12:02:00', 'active'),
(12, 55, 13, 2, 'Quality was lower than expected', '2026-08-18 15:42:00', 'active'),
(15, 14, 16, 4, 'Very satisfied with this purchase', '2026-08-19 14:27:00', 'active'),
(18, 36, 19, 5, 'Excellent value for money', '2026-08-21 15:47:00', 'active'),
(21, 61, 22, 1, 'Product did not meet my expectations', '2026-08-21 14:08:00', 'active'),
(24, 80, 25, 4, 'Good quality and nice design', '2026-08-22 12:33:00', 'active'),
(27, 98, 28, 5, 'Perfect product and highly satisfied', '2026-08-22 15:12:00', 'active'),
(30, 116, 31, 3, 'Average product but works well', '2026-08-23 13:49:00', 'active'),
(33, 19, 34, 4, 'Good quality and easy to use', '2026-08-24 14:32:00', 'active'),
(36, 41, 37, 5, 'One of the best products I purchased', '2026-08-21 16:50:00', 'active'),
(39, 64, 40, 2, 'Not as good as I expected', '2026-08-25 12:37:00', 'inactive'),
(42, 87, 43, 4, 'Product matches the description', '2026-08-26 16:52:00', 'active'),
(45, 109, 46, 5, 'Great product and excellent condition', '2026-08-27 16:12:00', 'active'),
(48, 13, 49, 3, 'Decent product for everyday use', '2026-08-27 15:09:00', 'active'),
(1, 37, 52, 1, 'Very disappointed with the quality', '2026-08-28 15:22:00', 'inactive'),
(4, 62, 55, 5, 'Absolutely worth the price', '2026-08-26 12:06:00', 'active'),
(7, 85, 58, 4, 'Works exactly as expected', '2026-08-27 09:56:00', 'active'),
(10, 108, 61, 3, 'Nothing special but does the job', '2026-08-27 15:33:00', 'active'),
(13, 10, 64, 5, 'Fantastic quality and packaging', '2026-08-31 13:52:00', 'active'),
(16, 32, 67, 4, 'Very nice product overall', '2026-08-29 11:18:00', 'active'),
(19, 54, 70, 2, 'Product could be much better', '2026-09-02 16:18:00', 'active'),
(22, 77, 73, 5, 'Excellent purchase and very happy', '2026-08-30 16:52:00', 'active'),
(25, 99, 76, 4, 'Good product for the price', '2026-08-31 13:33:00', 'active'),
(28, 2, 79, 3, 'Average quality but usable', '2026-09-01 12:36:00', 'active'),
(31, 23, 82, 5, 'Exceeded my expectations', '2026-09-02 09:42:00', 'active'),
(34, 46, 85, 1, 'Poor quality and disappointing', '2026-09-02 15:35:00', 'inactive'),
(37, 67, 88, 4, 'Nice product and good packaging', '2026-09-06 14:18:00', 'active'),
(40, 90, 91, 5, 'Excellent and very reliable product', '2026-09-04 11:38:00', 'active'),
(43, 113, 94, 3, 'It works but could be improved', '2026-09-04 08:00:00', 'active'),
(46, 14, 97, 4, 'Satisfied with the overall quality', '2026-09-04 08:00:00', 'active'),
(49, 43, 100, 5, 'Perfect condition and great quality', '2026-09-04 08:00:00', 'active'),
(2, 66, 103, 2, 'Expected better material quality', '2026-09-05 19:10:00', 'active'),
(5, 89, 106, 4, 'Good experience overall', '2026-09-06 09:34:00', 'active'),
(8, 111, 109, 5, 'Very impressive product', '2026-09-06 15:43:00', 'active'),
(11, 13, 112, 3, 'Reasonable quality for the price', '2026-09-07 14:19:00', 'active'),
(14, 37, 115, 1, 'Product stopped working quickly', '2026-09-08 11:13:00', 'inactive'),
(17, 61, 118, 5, 'Excellent quality and performance', '2026-09-09 10:04:00', 'active'),
(20, 83, 121, 4, 'Very good and useful product', '2026-09-09 17:50:00', 'active'),
(23, 107, 124, 3, 'The product is okay overall', '2026-09-10 13:18:00', 'active'),
(26, 12, 127, 5, 'Really happy with this purchase', '2026-09-11 12:36:00', 'active'),
(29, 36, 130, 4, 'Good quality and fair price', '2026-09-12 09:31:00', 'active'),
(32, 60, 133, 2, 'Not satisfied with the material', '2026-09-13 14:50:00', 'active'),
(35, 84, 136, 5, 'Everything was perfect', '2026-09-13 14:51:00', 'active'),
(38, 108, 139, 4, 'Good product and works properly', '2026-09-14 15:15:00', 'active'),
(41, 11, 142, 3, 'Acceptable but nothing exceptional', '2026-09-15 10:11:00', 'active'),
(44, 35, 145, 5, 'Excellent product and would buy again', '2026-09-15 16:48:00', 'active'),
(47, 59, 148, 1, 'Very poor quality product', '2026-09-16 13:42:00', 'inactive'),
(50, 83, 151, 4, 'Good value and useful product', '2026-09-17 12:45:00', 'active'),
(3, 105, 154, 5, 'Great quality and fast delivery', '2026-08-16 12:49:00', 'active'),
(6, 2, 157, 3, 'Product is fine for normal use', '2026-08-18 14:42:00', 'active'),
(9, 26, 160, 4, 'Satisfied with my order', '2026-08-17 12:02:00', 'active'),
(12, 50, 163, 5, 'Very good quality product', '2026-08-18 15:42:00', 'active'),
(15, 74, 166, 2, 'Could be better for this price', '2026-08-19 14:27:00', 'active'),
(18, 97, 169, 4, 'Works well and looks nice', '2026-08-21 15:47:00', 'active'),
(21, 118, 172, 5, 'Fantastic product and great value', '2026-08-21 14:08:00', 'active'),
(24, 23, 175, 3, 'Average but still useful', '2026-08-22 12:33:00', 'active'),
(27, 47, 178, 1, 'Did not work as advertised', '2026-08-22 15:12:00', 'inactive'),
(30, 71, 181, 5, 'Very satisfied with the product', '2026-08-23 13:49:00', 'active'),
(33, 95, 184, 4, 'Good product with nice quality', '2026-08-24 14:32:00', 'active'),
(36, 117, 187, 3, 'It is okay for the price', '2026-08-21 16:50:00', 'active'),
(39, 21, 190, 5, 'Excellent quality and design', '2026-08-25 12:37:00', 'active'),
(42, 45, 193, 4, 'Very useful and well made', '2026-08-26 16:52:00', 'active'),
(45, 69, 196, 2, 'Quality needs improvement', '2026-08-27 16:12:00', 'active'),
(48, 93, 199, 5, 'Exactly what I was looking for', '2026-08-27 15:09:00', 'active'),
(1, 8, 202, 4, 'Nice product and good value', '2026-08-28 15:22:00', 'active'),
(4, 32, 205, 3, 'Product works as expected', '2026-08-26 12:06:00', 'active'),
(7, 56, 208, 5, 'Excellent purchase overall', '2026-08-27 09:56:00', 'active'),
(10, 80, 211, 4, 'Very good product and reliable', '2026-08-27 15:33:00', 'active'),
(13, 104, 214, 3, 'Good but there is room for improvement', '2026-08-31 13:52:00', 'active'),
(16, 7, 217, 5, 'Amazing product for the price', '2026-08-29 11:18:00', 'active'),
(19, 31, 220, 2, 'The quality was disappointing', '2026-09-02 16:18:00', 'active'),
(22, 55, 223, 4, 'Works perfectly for my needs', '2026-08-30 16:52:00', 'active'),
(25, 79, 226, 5, 'Excellent quality and packaging', '2026-08-31 13:33:00', 'active'),
(28, 103, 229, 3, 'Average product overall', '2026-09-01 12:36:00', 'active'),
(31, 6, 232, 1, 'Product arrived in poor condition', '2026-09-02 09:42:00', 'inactive'),
(34, 30, 235, 5, 'Very happy with this product', '2026-09-02 15:35:00', 'active'),
(37, 54, 238, 4, 'Good quality and reasonable price', '2026-09-06 14:18:00', 'active'),
(40, 78, 241, 5, 'Excellent performance and quality', '2026-09-04 11:38:00', 'active'),
(43, 102, 244, 3, 'Decent product for the cost', '2026-09-04 08:00:00', 'active'),
(46, 5, 247, 4, 'Very satisfied with the quality', '2026-09-04 08:00:00', 'active'),
(49, 29, 250, 2, 'Not quite what I expected', '2026-09-04 08:00:00', 'active'),
(2, 53, 253, 5, 'Great product and worth buying', '2026-09-05 19:10:00', 'active'),
(5, 77, 256, 4, 'Good product with solid quality', '2026-09-06 09:34:00', 'active'),
(8, 101, 259, 3, 'Product is acceptable', '2026-09-06 15:43:00', 'active'),
(11, 4, 262, 5, 'Really excellent product', '2026-09-07 14:19:00', 'active'),
(14, 28, 265, 1, 'Very disappointed with this purchase', '2026-09-08 11:13:00', 'inactive'),
(17, 52, 268, 4, 'Good quality overall', '2026-09-09 10:04:00', 'active'),
(20, 76, 271, 5, 'Perfect product and great experience', '2026-09-09 17:50:00', 'active'),
(23, 100, 274, 4, 'Very nice and well made', '2026-09-10 13:18:00', 'active'),
(26, 3, 277, 3, 'Average quality but acceptable', '2026-09-11 12:36:00', 'active'),
(29, 27, 280, 5, 'Excellent product for daily use', '2026-09-12 09:31:00', 'active'),
(32, 51, 283, 2, 'Expected better quality', '2026-09-13 14:50:00', 'active'),
(35, 75, 286, 4, 'Good product and nice finish', '2026-09-13 14:51:00', 'active'),
(38, 99, 289, 5, 'Very impressive quality', '2026-09-14 15:15:00', 'active'),
(41, 2, 292, 3, 'Works fine but nothing special', '2026-09-15 10:11:00', 'active'),
(44, 26, 295, 4, 'Good value for the money', '2026-09-15 16:48:00', 'active'),
(47, 50, 298, 1, 'Product was not good quality', '2026-09-16 13:42:00', 'inactive'),
(50, 74, 301, 5, 'Excellent product and service', '2026-09-17 12:45:00', 'active'),
(3, 98, 304, 4, 'Very useful and good quality', '2026-08-16 12:49:00', 'active'),
(6, 1, 307, 3, 'The product is satisfactory', '2026-08-18 14:42:00', 'active'),
(9, 25, 310, 5, 'Amazing product and great quality', '2026-08-17 12:02:00', 'active'),
(12, 49, 313, 4, 'Good quality and works well', '2026-08-18 15:42:00', 'active'),
(15, 73, 316, 2, 'Product was below expectations', '2026-08-19 14:27:00', 'active'),
(18, 97, 319, 5, 'Perfect and exactly as described', '2026-08-21 15:47:00', 'active'),
(21, 120, 322, 4, 'Nice product and reliable', '2026-08-21 14:08:00', 'active'),
(24, 22, 325, 3, 'Acceptable product for the price', '2026-08-22 12:33:00', 'active'),
(27, 46, 328, 5, 'Very happy with my purchase', '2026-08-22 15:12:00', 'active'),
(30, 70, 331, 4, 'Good product and nice design', '2026-08-23 13:49:00', 'active'),
(33, 94, 334, 1, 'Product quality was very poor', '2026-08-24 14:32:00', 'inactive'),
(36, 118, 337, 5, 'Excellent quality for the price', '2026-08-23 15:20:00', 'active'),
(39, 21, 340, 3, 'Product is fine and works properly', '2026-08-24 17:45:00', 'active'),
(42, 45, 343, 4, 'Satisfied with the purchase', '2026-08-26 16:52:00', 'active'),
(45, 69, 346, 5, 'Great quality and excellent product', '2026-08-27 16:12:00', 'active'),
(48, 93, 349, 2, 'Not worth the price in my opinion', '2026-08-27 14:15:00', 'active'),
(1, 117, 352, 4, 'Good product and easy to use', '2026-08-28 16:40:00', 'active'),
(4, 20, 355, 5, 'Excellent and highly recommended', '2026-08-29 10:00:00', 'active'),
(7, 44, 358, 3, 'Average experience overall', '2026-08-30 12:25:00', 'active');

INSERT INTO seller_settlements
(seller_id, period_start, period_end, gross_sales, commission_amount, refund_amount, net_amount, paid_at, status)
VALUES
(1, '2026-01-01', '2026-01-31', 18450.0, 922.5, 180.0, 17347.5, '2026-02-03 10:15:00', 'paid'),
(2, '2026-01-01', '2026-01-31', 12780.5, 639.03, 95.0, 12046.47, '2026-02-03 11:20:00', 'paid'),
(3, '2026-01-01', '2026-01-31', 22150.75, 1107.54, 320.0, 20723.21, '2026-02-04 09:45:00', 'paid'),
(4, '2026-01-01', '2026-01-31', 9650.0, 482.5, 75.0, 9092.5, '2026-02-04 14:10:00', 'paid'),
(5, '2026-01-01', '2026-01-31', 15320.4, 766.02, 140.0, 14414.38, '2026-02-05 10:30:00', 'paid'),
(6, '2026-01-01', '2026-01-31', 18750.0, 937.5, 210.0, 17602.5, '2026-02-05 13:25:00', 'paid'),
(7, '2026-01-01', '2026-01-31', 11240.8, 562.04, 90.0, 10588.76, '2026-02-06 09:20:00', 'paid'),
(8, '2026-01-01', '2026-01-31', 24680.0, 1234.0, 410.0, 23036.0, '2026-02-06 15:40:00', 'paid'),
(9, '2026-01-01', '2026-01-31', 8750.25, 437.51, 60.0, 8252.74, '2026-02-07 10:05:00', 'paid'),
(10, '2026-01-01', '2026-01-31', 13450.6, 672.53, 125.0, 12653.07, '2026-02-07 12:15:00', 'paid'),
(11, '2026-02-01', '2026-02-28', 19840.0, 992.0, 175.0, 18673.0, '2026-03-03 09:50:00', 'paid'),
(12, '2026-02-01', '2026-02-28', 14560.3, 728.02, 120.0, 13712.28, '2026-03-03 11:35:00', 'paid'),
(13, '2026-02-01', '2026-02-28', 17250.0, 862.5, 260.0, 16127.5, '2026-03-04 10:10:00', 'paid'),
(14, '2026-02-01', '2026-02-28', 10320.75, 516.04, 80.0, 9724.71, '2026-03-04 13:45:00', 'paid'),
(15, '2026-02-01', '2026-02-28', 21980.9, 1099.05, 350.0, 20531.85, '2026-03-05 09:30:00', 'paid'),
(16, '2026-02-01', '2026-02-28', 12875.0, 643.75, 100.0, 12131.25, '2026-03-05 14:20:00', 'paid'),
(17, '2026-02-01', '2026-02-28', 16740.5, 837.03, 145.0, 15758.47, NULL, 'pending'),
(18, '2026-02-01', '2026-02-28', 9320.0, 466.0, 70.0, 8784.0, NULL, 'pending'),
(19, '2026-02-01', '2026-02-28', 25460.25, 1273.01, 500.0, 23687.24, NULL, 'pending'),
(20, '2026-02-01', '2026-02-28', 11890.8, 594.54, 90.0, 11206.26, NULL, 'pending'),
(1, '2026-02-01', '2026-02-28', 20560.0, 1028.0, 220.0, 19312.0, '2026-03-06 10:25:00', 'paid'),
(2, '2026-02-01', '2026-02-28', 13980.45, 699.02, 110.0, 13171.43, '2026-03-06 12:40:00', 'paid'),
(3, '2026-02-01', '2026-02-28', 23120.0, 1156.0, 275.0, 21689.0, '2026-03-07 09:15:00', 'paid'),
(4, '2026-02-01', '2026-02-28', 10875.6, 543.78, 85.0, 10246.82, '2026-03-07 13:30:00', 'paid'),
(5, '2026-02-01', '2026-02-28', 16140.25, 807.01, 160.0, 15173.24, '2026-03-08 11:05:00', 'paid'),
(6, '2026-02-01', '2026-02-28', 19250.0, 962.5, 240.0, 18047.5, '2026-03-08 14:15:00', 'paid'),
(7, '2026-02-01', '2026-02-28', 12480.9, 624.05, 95.0, 11761.85, '2026-03-09 10:40:00', 'paid'),
(8, '2026-02-01', '2026-02-28', 26840.0, 1342.0, 460.0, 25038.0, '2026-03-09 15:20:00', 'paid'),
(9, '2026-02-01', '2026-02-28', 9840.5, 492.03, 65.0, 9283.47, NULL, 'pending'),
(10, '2026-02-01', '2026-02-28', 15120.0, 756.0, 130.0, 14234.0, NULL, 'pending');





-- Sale means an order with a payment whose status is 'paid'.
-- Product revenue = quantity * unit_price - item discount, before refunds.
-- orders has no creation date, so queries 19 and 20 use its AUTO_INCREMENT id.

-- 1. Show every product with its seller and category.
SELECT p.id, p.product_name, p.price, s.store_name, c.category_name
FROM products AS p
JOIN sellers AS s ON s.id = p.seller_id
JOIN categories AS c ON c.id = p.category_id;

-- 2. Show currently available active products.
SELECT id, product_name, stock_quantity, price
FROM products
WHERE status = 'active' AND stock_quantity > 0;

-- 3. Show products that are out of stock.
SELECT id, product_name, stock_quantity
FROM products
WHERE stock_quantity = 0;

-- 4. Show products at or below minimum stock, excluding zero-stock items.
SELECT id, product_name, stock_quantity, minimum_stock
FROM products
WHERE stock_quantity > 0 AND stock_quantity <= minimum_stock;

-- 5. Show products never included in a paid order.
SELECT p.id, p.product_name
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items AS oi
    JOIN payments AS pay ON pay.order_id = oi.order_id AND pay.status = 'paid'
    WHERE oi.product_id = p.id
);

-- 6. Show products that sold more than 100 units in paid orders.
SELECT p.id, p.product_name, SUM(oi.quantity) AS units_sold
FROM products AS p
JOIN order_items AS oi ON oi.product_id = p.id
WHERE EXISTS (
    SELECT 1 FROM payments AS pay
    WHERE pay.order_id = oi.order_id AND pay.status = 'paid'
)
GROUP BY p.id, p.product_name
HAVING SUM(oi.quantity) > 100
ORDER BY units_sold DESC;

-- 7. Total units sold per product, including products with zero sales.
SELECT p.id, p.product_name,
       COALESCE(SUM(CASE WHEN pay.id IS NOT NULL THEN oi.quantity ELSE 0 END), 0)
           AS units_sold
FROM products AS p
LEFT JOIN order_items AS oi ON oi.product_id = p.id
LEFT JOIN payments AS pay ON pay.order_id = oi.order_id AND pay.status = 'paid'
GROUP BY p.id, p.product_name
ORDER BY units_sold DESC;

-- 8. Total product revenue after item discounts, including zero-sales products.
SELECT p.id, p.product_name,
       COALESCE(ROUND(SUM(CASE WHEN pay.id IS NOT NULL
           THEN oi.quantity * oi.unit_price - oi.discount_amount
           ELSE 0 END), 2), 0) AS product_revenue
FROM products AS p
LEFT JOIN order_items AS oi ON oi.product_id = p.id
LEFT JOIN payments AS pay ON pay.order_id = oi.order_id AND pay.status = 'paid'
GROUP BY p.id, p.product_name
ORDER BY product_revenue DESC;

-- 9. Top 10 products by units sold.
SELECT p.id, p.product_name, SUM(oi.quantity) AS units_sold
FROM products AS p
JOIN order_items AS oi ON oi.product_id = p.id
WHERE EXISTS (
    SELECT 1 FROM payments AS pay
    WHERE pay.order_id = oi.order_id AND pay.status = 'paid'
)
GROUP BY p.id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- 10. Top 10 products by revenue after item discounts.
SELECT p.id, p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price - oi.discount_amount), 2)
           AS product_revenue
FROM products AS p
JOIN order_items AS oi ON oi.product_id = p.id
WHERE EXISTS (
    SELECT 1 FROM payments AS pay
    WHERE pay.order_id = oi.order_id AND pay.status = 'paid'
)
GROUP BY p.id, p.product_name
ORDER BY product_revenue DESC
LIMIT 10;

-- 11. Average product price per category; empty categories show NULL.
SELECT c.id, c.category_name, ROUND(AVG(p.price), 2) AS average_price
FROM categories AS c
LEFT JOIN products AS p ON p.category_id = c.id
GROUP BY c.id, c.category_name;

-- 12. Products priced above their own category's average.
SELECT p.id, p.product_name, p.price, c.category_name
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
);

-- 13. The most expensive product in each category, including ties.
SELECT c.category_name, p.id, p.product_name, p.price
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
);

-- 14. Second distinct highest price per category, including ties.
SELECT c.category_name, p.id, p.product_name, p.price
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
      AND p2.price < (
          SELECT MAX(p3.price)
          FROM products AS p3
          WHERE p3.category_id = p.category_id
      )
);

-- 15. Customers who have never placed an order.
SELECT c.id, c.full_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM orders AS o WHERE o.customer_id = c.id
);

-- 16. Customers with more than 5 orders, regardless of payment status.
SELECT c.id, c.full_name, COUNT(o.id) AS order_count
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.full_name
HAVING COUNT(o.id) > 5;

-- 17. Total paid spending for each customer; customers without payments show zero.
SELECT c.id, c.full_name,
       COALESCE(ROUND(SUM(pay.amount), 2), 0) AS total_spent
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
LEFT JOIN payments AS pay ON pay.order_id = o.id AND pay.status = 'paid'
GROUP BY c.id, c.full_name
ORDER BY total_spent DESC;

-- 18. Customers spending more than the average across all customers (zeroes included).
WITH spending AS (
    SELECT c.id, c.full_name,
           COALESCE(SUM(pay.amount), 0) AS total_spent
    FROM customers AS c
    LEFT JOIN orders AS o ON o.customer_id = c.id
    LEFT JOIN payments AS pay ON pay.order_id = o.id AND pay.status = 'paid'
    GROUP BY c.id, c.full_name
)
SELECT id, full_name, ROUND(total_spent, 2) AS total_spent
FROM spending
WHERE total_spent > (SELECT AVG(total_spent) FROM spending)
ORDER BY total_spent DESC;

-- 19. Latest order per customer by highest order id, including ties only if possible.
SELECT c.id AS customer_id, c.full_name,
       o.id AS order_id, o.order_number, o.total_amount, o.status
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
WHERE o.id = (
    SELECT MAX(o2.id) FROM orders AS o2 WHERE o2.customer_id = c.id
);

-- 20. First order per customer by lowest order id.
SELECT c.id AS customer_id, c.full_name,
       o.id AS order_id, o.order_number, o.total_amount, o.status
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
WHERE o.id = (
    SELECT MIN(o2.id) FROM orders AS o2 WHERE o2.customer_id = c.id
);

-- 21. Average order value per customer, regardless of payment status.
SELECT c.id, c.full_name,
       ROUND(AVG(o.total_amount), 2) AS average_order_value
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.full_name;

-- 22. Customers who purchased from more than 5 distinct sellers.
SELECT c.id, c.full_name,
       COUNT(DISTINCT oi.seller_id) AS seller_count
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id = o.id
WHERE EXISTS (
    SELECT 1 FROM payments AS pay
    WHERE pay.order_id = o.id AND pay.status = 'paid'
)
GROUP BY c.id, c.full_name
HAVING COUNT(DISTINCT oi.seller_id) > 5;

-- 23. Customers who bought the same product in more than one distinct paid order.
SELECT c.id AS customer_id, c.full_name,
       p.id AS product_id, p.product_name,
       COUNT(DISTINCT o.id) AS order_count
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id = o.id
JOIN products AS p ON p.id = oi.product_id
WHERE EXISTS (
    SELECT 1 FROM payments AS pay
    WHERE pay.order_id = o.id AND pay.status = 'paid'
)
GROUP BY c.id, c.full_name, p.id, p.product_name
HAVING COUNT(DISTINCT o.id) > 1
ORDER BY c.id, order_count DESC;

-- 24. Orders containing products from more than one seller.
SELECT o.id, o.order_number,
       COUNT(DISTINCT oi.seller_id) AS seller_count
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY o.id, o.order_number
HAVING COUNT(DISTINCT oi.seller_id) > 1;

-- 25. عرض Orders غير المدفوعة
SELECT o.id, o.order_number, o.customer_id, o.total_amount, o.ordered_at
FROM orders o
LEFT JOIN payments p ON p.order_id = o.id
WHERE p.id IS NULL
   OR p.status <> 'paid';


-- 26. عرض Orders المدفوعة ولم يتم شحنها
SELECT o.id, o.order_number, o.customer_id, p.paid_at
FROM orders o
JOIN payments p ON p.order_id = o.id
LEFT JOIN shipments s ON s.order_id = o.id
WHERE p.status = 'paid'
  AND (s.id IS NULL OR s.shipped_at IS NULL);


-- 27. عرض Orders التي تجاوزت Expected Delivery ولم تصل
SELECT
    o.id,
    o.order_number,
    s.expected_delivery,
    s.status
FROM orders o
JOIN shipments s ON s.order_id = o.id
WHERE s.expected_delivery < NOW()
  AND s.delivered_at IS NULL;


-- 28. حساب متوسط مدة التوصيل
SELECT
    AVG(TIMESTAMPDIFF(DAY, shipped_at, delivered_at))
        AS average_delivery_days
FROM shipments
WHERE shipped_at IS NOT NULL
  AND delivered_at IS NOT NULL;


-- 29. عرض Shipments التي استغرقت أكثر من متوسط مدة التوصيل
SELECT
    s.id,
    s.order_id,
    s.tracking_number,
    s.shipped_at,
    s.delivered_at,
    TIMESTAMPDIFF(DAY, s.shipped_at, s.delivered_at) AS delivery_days
FROM shipments s
WHERE s.shipped_at IS NOT NULL
  AND s.delivered_at IS NOT NULL
  AND TIMESTAMPDIFF(DAY, s.shipped_at, s.delivered_at) >
      (
        SELECT AVG(TIMESTAMPDIFF(DAY, shipped_at, delivered_at))
        FROM shipments
        WHERE shipped_at IS NOT NULL
          AND delivered_at IS NOT NULL
      );


-- 30. حساب عدد Orders لكل شهر
SELECT
    DATE_FORMAT(ordered_at, '%Y-%m') AS month,
    COUNT(*) AS orders_count
FROM orders
GROUP BY DATE_FORMAT(ordered_at, '%Y-%m')
ORDER BY month;


-- 31. حساب Revenue لكل شهر
SELECT
    DATE_FORMAT(paid_at, '%Y-%m') AS month,
    SUM(amount) AS revenue
FROM payments
WHERE status = 'paid'
GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
ORDER BY month;


-- 32. عرض الشهر صاحب أعلى Revenue
SELECT
    DATE_FORMAT(paid_at, '%Y-%m') AS month,
    SUM(amount) AS revenue
FROM payments
WHERE status = 'paid'
GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
ORDER BY revenue DESC
LIMIT 1;


-- 33. حساب Average Order Value لكل شهر
SELECT
    DATE_FORMAT(ordered_at, '%Y-%m') AS month,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY DATE_FORMAT(ordered_at, '%Y-%m')
ORDER BY month;


-- 34. مقارنة Revenue الشهر الحالي بالشهر السابق
SELECT
    current_month.month,
    current_month.revenue AS current_revenue,
    previous_month.revenue AS previous_revenue,
    current_month.revenue - previous_month.revenue AS difference
FROM
(
    SELECT
        DATE_FORMAT(paid_at, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
) current_month
LEFT JOIN
(
    SELECT
        DATE_FORMAT(paid_at, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
) previous_month
ON previous_month.month =
   DATE_FORMAT(
       DATE_SUB(
           STR_TO_DATE(CONCAT(current_month.month, '-01'), '%Y-%m-%d'),
           INTERVAL 1 MONTH
       ),
       '%Y-%m'
   );


-- 35. حساب Growth Percentage بين الأشهر
SELECT
    current_month.month,
    current_month.revenue AS current_revenue,
    previous_month.revenue AS previous_revenue,
    ROUND(
        (
            (current_month.revenue - previous_month.revenue)
            / NULLIF(previous_month.revenue, 0)
        ) * 100,
        2
    ) AS growth_percentage
FROM
(
    SELECT
        DATE_FORMAT(paid_at, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
) current_month
LEFT JOIN
(
    SELECT
        DATE_FORMAT(paid_at, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
) previous_month
ON previous_month.month =
   DATE_FORMAT(
       DATE_SUB(
           STR_TO_DATE(CONCAT(current_month.month, '-01'), '%Y-%m-%d'),
           INTERVAL 1 MONTH
       ),
       '%Y-%m'
   );


-- 36. عرض Sellers الذين لم يحققوا أي Sale
SELECT
    s.id,
    s.store_name
FROM sellers s
LEFT JOIN order_items oi
    ON oi.seller_id = s.id
WHERE oi.id IS NULL;


-- 37. حساب Revenue لكل Seller
SELECT
    s.id,
    s.store_name,
    SUM(oi.seller_amount) AS revenue
FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
GROUP BY s.id, s.store_name
ORDER BY revenue DESC;


-- 38. حساب Platform Commission لكل Seller
SELECT
    s.id,
    s.store_name,
    SUM(oi.platform_commission) AS platform_commission
FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
GROUP BY s.id, s.store_name
ORDER BY platform_commission DESC;


-- 39. حساب المبلغ المستحق لكل Seller بعد Commission و Refunds
SELECT
    s.id,
    s.store_name,
    COALESCE(SUM(oi.seller_amount), 0) AS gross_amount,
    COALESCE(SUM(oi.platform_commission), 0) AS commission,
    COALESCE(SUM(rf.amount), 0) AS refunds,
    COALESCE(SUM(oi.seller_amount), 0)
    - COALESCE(SUM(oi.platform_commission), 0)
    - COALESCE(SUM(rf.amount), 0) AS payable_amount
FROM sellers s
LEFT JOIN order_items oi
    ON oi.seller_id = s.id
LEFT JOIN returns r
    ON r.order_item_id = oi.id
   AND r.status = 'completed'
LEFT JOIN refunds rf
    ON rf.return_id = r.id
   AND rf.status = 'completed'
GROUP BY s.id, s.store_name;


-- 40. عرض Seller الذي لديه أكبر عدد من Customers مختلفين
SELECT
    s.id,
    s.store_name,
    COUNT(DISTINCT o.customer_id) AS customers_count
FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
JOIN orders o
    ON o.id = oi.order_id
GROUP BY s.id, s.store_name
ORDER BY customers_count DESC
LIMIT 1;


-- 41. عرض Seller الذي لديه أعلى Average Order Item Value
SELECT
    s.id,
    s.store_name,
    AVG(oi.unit_price * oi.quantity) AS average_order_item_value
FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
GROUP BY s.id, s.store_name
ORDER BY average_order_item_value DESC
LIMIT 1;


-- 42. عرض المنتجات ذات أعلى Return Rate
SELECT
    p.id,
    p.product_name,
    COALESCE(SUM(r.quantity), 0) AS returned_quantity,
    SUM(oi.quantity) AS sold_quantity,
    ROUND(
        COALESCE(SUM(r.quantity), 0)
        / NULLIF(SUM(oi.quantity), 0) * 100,
        2
    ) AS return_rate
FROM products p
JOIN order_items oi
    ON oi.product_id = p.id
LEFT JOIN returns r
    ON r.order_item_id = oi.id
   AND r.status = 'completed'
GROUP BY p.id, p.product_name
ORDER BY return_rate DESC;


-- 43. عرض Sellers ذوي أعلى Return Rate
SELECT
    s.id,
    s.store_name,
    COALESCE(SUM(r.quantity), 0) AS returned_quantity,
    SUM(oi.quantity) AS sold_quantity,
    ROUND(
        COALESCE(SUM(r.quantity), 0)
        / NULLIF(SUM(oi.quantity), 0) * 100,
        2
    ) AS return_rate
FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
LEFT JOIN returns r
    ON r.order_item_id = oi.id
   AND r.status = 'completed'
GROUP BY s.id, s.store_name
ORDER BY return_rate DESC;


-- 44. عرض Customers الذين قاموا بعدد Returns أعلى من المتوسط
SELECT
    c.id,
    c.full_name,
    COUNT(r.id) AS returns_count
FROM customers c
JOIN orders o
    ON o.customer_id = c.id
JOIN order_items oi
    ON oi.order_id = o.id
JOIN returns r
    ON r.order_item_id = oi.id
GROUP BY c.id, c.full_name
HAVING COUNT(r.id) >
(
    SELECT AVG(return_count)
    FROM
    (
        SELECT
            o.customer_id,
            COUNT(r.id) AS return_count
        FROM orders o
        JOIN order_items oi
            ON oi.order_id = o.id
        JOIN returns r
            ON r.order_item_id = oi.id
        GROUP BY o.customer_id
    ) x
);


-- 45. عرض المنتجات التي متوسط تقييمها أقل من 3
SELECT
    p.id,
    p.product_name,
    AVG(r.rating) AS average_rating
FROM products p
JOIN reviews r
    ON r.product_id = p.id
GROUP BY p.id, p.product_name
HAVING AVG(r.rating) < 3;


-- 46. حساب Average Rating لكل Product
SELECT
    p.id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM products p
LEFT JOIN reviews r
    ON r.product_id = p.id
GROUP BY p.id, p.product_name
ORDER BY average_rating DESC;


-- 47. عرض المنتجات التي لديها 10 Reviews على الأقل ومتوسط تقييم أعلى من 4
SELECT
    p.id,
    p.product_name,
    COUNT(r.id) AS reviews_count,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM products p
JOIN reviews r
    ON r.product_id = p.id
GROUP BY p.id, p.product_name
HAVING COUNT(r.id) >= 10
   AND AVG(r.rating) > 4;


-- 48. عرض Customers الذين كتبوا Review بدون شراء المنتج
SELECT
    r.id AS review_id,
    r.customer_id,
    r.product_id,
    r.order_item_id,
    r.rating,
    r.comment
FROM reviews r
JOIN order_items oi
    ON oi.id = r.order_item_id
JOIN orders o
    ON o.id = oi.order_id
WHERE r.customer_id <> o.customer_id;


-- 49. عرض الـCoupons الأكثر استخدامًا
SELECT
    c.id,
    c.code,
    COUNT(o.id) AS usage_count
FROM coupons c
JOIN orders o
    ON o.coupon_id = c.id
GROUP BY c.id, c.code
ORDER BY usage_count DESC;


-- 50. حساب إجمالي قيمة الخصومات الناتجة عن كل Coupon
SELECT
    c.id,
    c.code,
    COALESCE(SUM(o.discount_amount), 0) AS total_discount
FROM coupons c
LEFT JOIN orders o
    ON o.coupon_id = c.id
GROUP BY c.id, c.code
ORDER BY total_discount DESC;









WITH RECURSIVE category_tree AS (
   
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    

    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ct.level + 1 AS level,
        CONCAT(ct.full_path, ' > ', c.category_name) AS full_path,
        CONCAT(ct.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_tree AS ct 
        ON c.parent_id = ct.category_id
    WHERE c.parent_id IS NOT NULL
)
SELECT 
    category_id,
    category_name,
    parent_id,
    level,
    full_path,
    status,
    REPEAT('  ', level - 1) AS indent
FROM category_tree
ORDER BY path_ids;




WITH RECURSIVE category_descendants AS (
   
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE id = 1 
    
    UNION ALL
    
  
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        cd.level + 1 AS level,
        CONCAT(cd.full_path, ' > ', c.category_name) AS full_path,
        CONCAT(cd.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_descendants AS cd 
        ON c.parent_id = cd.category_id
)
SELECT 
    category_id,
    category_name,
    parent_id,
    level,
    full_path,
    status,
    REPEAT('  ', level - 1) AS indent
FROM category_descendants
WHERE category_id != 1 
ORDER BY path_ids;



WITH RECURSIVE category_ancestors AS (
    
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE id = 10  
    
    UNION ALL
    
   
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ca.level + 1 AS level,
        CONCAT(c.category_name, ' > ', ca.full_path) AS full_path,
        CONCAT(c.id, ',', ca.path_ids) AS path_ids
    FROM categories AS c
    INNER JOIN category_ancestors AS ca 
        ON c.id = ca.parent_id
)
SELECT 
    category_id,
    category_name,
    parent_id,
    level,
    full_path,
    status
FROM category_ancestors
ORDER BY level;



WITH RECURSIVE category_tree AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ct.level + 1 AS level,
        CONCAT(ct.full_path, ' > ', c.category_name) AS full_path,
        CONCAT(ct.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_tree AS ct 
        ON c.parent_id = ct.category_id
)
SELECT 
    ct.category_id,
    ct.category_name,
    ct.parent_id,
    ct.level,
    ct.full_path,
    ct.status,
    COUNT(p.id) AS product_count,
    COALESCE(SUM(CASE WHEN p.status = 'active' THEN 1 ELSE 0 END), 0) AS active_products,
    REPEAT('  ', ct.level - 1) AS indent
FROM category_tree AS ct
LEFT JOIN products AS p ON p.category_id = ct.category_id
GROUP BY 
    ct.category_id,
    ct.category_name,
    ct.parent_id,
    ct.level,
    ct.full_path,
    ct.status
ORDER BY ct.path_ids;





WITH RECURSIVE category_tree AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ct.level + 1 AS level,
        CONCAT(ct.full_path, ' > ', c.category_name) AS full_path,
        CONCAT(ct.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_tree AS ct 
        ON c.parent_id = ct.category_id
),
leaf_categories AS (
    SELECT ct.category_id, ct.category_name, ct.full_path
    FROM category_tree AS ct
    WHERE NOT EXISTS (
        SELECT 1 FROM categories AS c WHERE c.parent_id = ct.category_id
    )
)
SELECT 
    lc.category_id,
    lc.category_name,
    lc.full_path,
    p.id AS product_id,
    p.product_name,
    p.price,
    p.stock_quantity,
    p.status,
    s.store_name
FROM leaf_categories AS lc
LEFT JOIN products AS p ON p.category_id = lc.category_id
LEFT JOIN sellers AS s ON s.id = p.seller_id
ORDER BY lc.category_id, p.id;



WITH RECURSIVE category_depth AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        1 AS depth
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        cd.depth + 1 AS depth
    FROM categories AS c
    INNER JOIN category_depth AS cd 
        ON c.parent_id = cd.category_id
)
SELECT 
    'Maximum Category Depth' AS metric,
    MAX(depth) AS value
FROM category_depth

UNION ALL

SELECT 
    'Total Categories' AS metric,
    COUNT(DISTINCT category_id) AS value
FROM category_depth

UNION ALL

SELECT 
    'Root Categories (No Parent)' AS metric,
    COUNT(*) AS value
FROM categories
WHERE parent_id IS NULL;





WITH RECURSIVE category_tree AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ct.level + 1 AS level,
        CONCAT(ct.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_tree AS ct 
        ON c.parent_id = ct.category_id
)
SELECT 
    ct.category_id,
    ct.category_name,
    ct.parent_id,
    ct.level,
    ct.status
FROM category_tree AS ct
WHERE ct.parent_id = (
    SELECT parent_id FROM categories WHERE id = 5 
)
ORDER BY ct.category_name;





WITH RECURSIVE category_ancestors AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        1 AS level,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE id = 15  
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        ca.level + 1 AS level,
        CONCAT(c.id, ',', ca.path_ids) AS path_ids
    FROM categories AS c
    INNER JOIN category_ancestors AS ca 
        ON c.id = ca.parent_id
)
SELECT 
    category_id,
    category_name,
    ROW_NUMBER() OVER (ORDER BY level) AS breadcrumb_position
FROM category_ancestors
ORDER BY level DESC;





WITH RECURSIVE category_tree AS (
    SELECT 
        id AS category_id,
        category_name,
        parent_id,
        status,
        1 AS level,
        category_name AS full_path,
        CAST(id AS CHAR(500)) AS path_ids
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id AS category_id,
        c.category_name,
        c.parent_id,
        c.status,
        ct.level + 1 AS level,
        CONCAT(ct.full_path, ' > ', c.category_name) AS full_path,
        CONCAT(ct.path_ids, ',', c.id) AS path_ids
    FROM categories AS c
    INNER JOIN category_tree AS ct 
        ON c.parent_id = ct.category_id
)
SELECT 
    ct.category_id,
    ct.category_name,
    ct.full_path,
    ct.level,
    COUNT(DISTINCT p.id) AS total_products,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price - oi.discount_amount), 2), 0) AS category_revenue,
    COALESCE(SUM(
        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM payments AS pay
                WHERE pay.order_id = oi.order_id
                  AND pay.status = 'paid'
            )
            THEN oi.quantity 
            ELSE 0 
        END
    ), 0) AS units_sold
FROM category_tree AS ct
LEFT JOIN products AS p ON p.category_id = ct.category_id
LEFT JOIN order_items AS oi ON oi.product_id = p.id
GROUP BY 
    ct.category_id,
    ct.category_name,
    ct.full_path,
    ct.level
ORDER BY ct.path_ids;




WITH RECURSIVE circular_check AS (
    SELECT 
        id AS start_category_id,
        id AS category_id,
        parent_id,
        CAST(id AS CHAR(500)) AS path,
        1 AS depth,
        0 AS cycle_found
    FROM categories
    WHERE parent_id IS NOT NULL

    UNION ALL

    SELECT 
        cc.start_category_id,
        c.id AS category_id,
        c.parent_id,
        CONCAT(cc.path, ',', c.id) AS path,
        cc.depth + 1 AS depth,
        CASE 
            WHEN FIND_IN_SET(c.id, cc.path) > 0 THEN 1 
            ELSE 0 
        END AS cycle_found
    FROM categories AS c
    INNER JOIN circular_check AS cc 
        ON c.id = cc.parent_id
    WHERE cc.depth < 100
)
SELECT 
    'Valid - No Circular References' AS validation_result
FROM DUAL                          
WHERE NOT EXISTS (
    SELECT 1 FROM circular_check 
    WHERE cycle_found = 1
)

UNION ALL

SELECT 
    CONCAT('ERROR - Circular Reference: Category ', start_category_id, ' has circular parent chain') AS validation_result
FROM circular_check 
WHERE cycle_found = 1
GROUP BY start_category_id;



ALTER TABLE products
ADD CONSTRAINT chk_products_price_positive
CHECK (price > 0);

ALTER TABLE products
ADD CONSTRAINT chk_products_stock_nonnegative
CHECK (stock_quantity >= 0);






DROP PROCEDURE IF EXISTS create_order;

DELIMITER $$

CREATE PROCEDURE create_order(
    IN p_customer_id INT,
    IN p_cart_id INT,
    IN p_coupon_code VARCHAR(100)
)
BEGIN
    DECLARE v_address_id INT DEFAULT NULL;
    DECLARE v_coupon_id INT DEFAULT NULL;
    DECLARE v_discount DECIMAL(12,2) DEFAULT 0;
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_order_id INT;
    DECLARE v_order_number VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* Customer active */
    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE id = p_customer_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer is not active';
    END IF;

    /* Active cart */
    IF NOT EXISTS (
        SELECT 1
        FROM carts
        WHERE id = p_cart_id
          AND customer_id = p_customer_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cart is not active or does not belong to customer';
    END IF;

    /* Default address */
    SELECT id
    INTO v_address_id
    FROM customer_addresses
    WHERE customer_id = p_customer_id
      AND is_default = 1
    LIMIT 1;

    IF v_address_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer has no default address';
    END IF;

    /* Cart must contain products */
    IF NOT EXISTS (
        SELECT 1
        FROM cart_items
        WHERE cart_id = p_cart_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cart is empty';
    END IF;

    /* Quantity must be positive */
    IF EXISTS (
        SELECT 1
        FROM cart_items
        WHERE cart_id = p_cart_id
          AND quantity <= 0
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cart contains invalid quantity';
    END IF;

    /* Lock products before checking stock */
    SELECT p.id
    FROM products AS p
    INNER JOIN cart_items AS ci
        ON ci.product_id = p.id
    WHERE ci.cart_id = p_cart_id
    FOR UPDATE;

    /* Products and sellers */
    IF EXISTS (
        SELECT 1
        FROM cart_items AS ci
        LEFT JOIN products AS p
            ON p.id = ci.product_id
        LEFT JOIN sellers AS s
            ON s.id = p.seller_id
        WHERE ci.cart_id = p_cart_id
          AND (
              p.id IS NULL
              OR s.id IS NULL
              OR p.status <> 'active'
              OR s.status <> 'active'
              OR p.stock_quantity < ci.quantity
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid product, seller or insufficient stock';
    END IF;

    /* Subtotal */
    SELECT COALESCE(SUM(ci.quantity * p.price), 0)
    INTO v_subtotal
    FROM cart_items AS ci
    INNER JOIN products AS p
        ON p.id = ci.product_id
    WHERE ci.cart_id = p_cart_id;

    /* Coupon */
    IF p_coupon_code IS NOT NULL THEN

        SELECT id
        INTO v_coupon_id
        FROM coupons
        WHERE code = p_coupon_code
          AND status = 'active'
          AND NOW() BETWEEN starts_at AND expires_at
          AND used_count < usage_limit
        LIMIT 1
        FOR UPDATE;

        IF v_coupon_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid or expired coupon';
        END IF;

        SELECT
            CASE
                WHEN discount_type = 'percentage'
                    THEN LEAST(
                        v_subtotal * discount_value / 100,
                        COALESCE(maximum_discount, v_subtotal)
                    )
                ELSE LEAST(discount_value, v_subtotal)
            END
        INTO v_discount
        FROM coupons
        WHERE id = v_coupon_id
          AND v_subtotal >= minimum_order;

        IF v_discount IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Minimum order amount not reached';
        END IF;

    END IF;

    SET v_total = v_subtotal - v_discount;

    /* Create Order */
    SET v_order_number = CONCAT('ORD-', UUID());

    INSERT INTO orders
    (
        order_number,
        customer_id,
        address_id,
        coupon_id,
        subtotal,
        discount_amount,
        shipping_cost,
        total_amount,
        status
    )
    VALUES
    (
        v_order_number,
        p_customer_id,
        v_address_id,
        v_coupon_id,
        v_subtotal,
        v_discount,
        0,
        v_total,
        'pending'
    );

    SET v_order_id = LAST_INSERT_ID();

    /* Create Order Items */
    INSERT INTO order_items
    (
        order_id,
        product_id,
        seller_id,
        quantity,
        unit_price,
        discount_amount,
        platform_commission,
        seller_amount,
        status
    )
    SELECT
        v_order_id,
        p.id,
        p.seller_id,
        ci.quantity,
        p.price,

        ROUND(
            (ci.quantity * p.price / v_subtotal) * v_discount,
            2
        ),

        ROUND(
            (
                (ci.quantity * p.price)
                -
                ((ci.quantity * p.price / v_subtotal) * v_discount)
            ) * s.commission_rate / 100,
            2
        ),

        ROUND(
            (
                (ci.quantity * p.price)
                -
                ((ci.quantity * p.price / v_subtotal) * v_discount)
            )
            -
            (
                (
                    (ci.quantity * p.price)
                    -
                    ((ci.quantity * p.price / v_subtotal) * v_discount)
                ) * s.commission_rate / 100
            ),
            2
        ),

        'active'

    FROM cart_items AS ci
    INNER JOIN products AS p
        ON p.id = ci.product_id
    INNER JOIN sellers AS s
        ON s.id = p.seller_id
    WHERE ci.cart_id = p_cart_id;

    /* Decrease stock */
    UPDATE products AS p
    INNER JOIN cart_items AS ci
        ON ci.product_id = p.id
    SET p.stock_quantity = p.stock_quantity - ci.quantity
    WHERE ci.cart_id = p_cart_id;

    /* Update out of stock products */
    UPDATE products
    SET status = 'out_of_stock'
    WHERE id IN (
        SELECT product_id
        FROM cart_items
        WHERE cart_id = p_cart_id
    )
    AND stock_quantity = 0;

    /* Update coupon usage */
    IF v_coupon_id IS NOT NULL THEN
        UPDATE coupons
        SET used_count = used_count + 1
        WHERE id = v_coupon_id;
    END IF;

    /* Cart converted */
    UPDATE carts
    SET status = 'converted'
    WHERE id = p_cart_id;

    COMMIT;

    SELECT *
    FROM orders
    WHERE id = v_order_id;
     END$$
DELIMITER ;


-- Overselling Challenge

DROP PROCEDURE IF EXISTS buy_product_safe;

DELIMITER $$

CREATE PROCEDURE buy_product_safe(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_price DECIMAL(12,2) DEFAULT NULL;
    DECLARE v_seller_id INT DEFAULT NULL;
    DECLARE v_order_id INT;
    DECLARE v_order_number VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* Quantity must be positive */
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    /* Ürün satırını kilitle */
    SELECT stock_quantity, price, seller_id
    INTO v_stock, v_price, v_seller_id
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;

    /* Product existence */
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found';
    END IF;

    /* Product and seller status */
    IF NOT EXISTS (
        SELECT 1
        FROM products AS p
        INNER JOIN sellers AS s
            ON s.id = p.seller_id
        WHERE p.id = p_product_id
          AND p.status = 'active'
          AND s.status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product or seller is not active';
    END IF;

    /* Stok kontrolü */
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    /* Müşteri kontrolü */
    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE id = p_customer_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer is not active';
    END IF;

    /* Sipariş numarası */
    SET v_order_number = CONCAT('ORD-', UUID());

    /* Sipariş oluştur */
    INSERT INTO orders
    (
        order_number,
        customer_id,
        subtotal,
        discount_amount,
        shipping_cost,
        total_amount,
        status
    )
    VALUES
    (
        v_order_number,
        p_customer_id,
        v_price * p_quantity,
        0,
        0,
        v_price * p_quantity,
        'pending'
    );

    SET v_order_id = LAST_INSERT_ID();

    /* Sipariş ürünü oluştur */
    INSERT INTO order_items
    (
        order_id,
        product_id,
        seller_id,
        quantity,
        unit_price,
        discount_amount,
        platform_commission,
        seller_amount,
        status
    )
    SELECT
        v_order_id,
        p_product_id,
        v_seller_id,
        p_quantity,
        v_price,
        0,
        0,
        v_price * p_quantity,
        'active';

    /* Stok azalt */
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE id = p_product_id;

    /* Stok 0 olduysa out_of_stock */
    UPDATE products
    SET status = 'out_of_stock'
    WHERE id = p_product_id
      AND stock_quantity = 0;

    COMMIT;

    SELECT
        v_order_id AS order_id,
        v_order_number AS order_number,
        p_product_id AS product_id,
        p_quantity AS quantity,
        v_stock - p_quantity AS remaining_stock;

END$$

DELIMITER ;


-- Atomic Stock Update


DROP PROCEDURE IF EXISTS atomic_stock_order;

DELIMITER $$

CREATE PROCEDURE atomic_stock_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(12,2);
    DECLARE v_seller_id INT;
    DECLARE v_order_id INT;
    DECLARE v_order_number VARCHAR(100);
    DECLARE v_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* التحقق من الكمية */
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than 0';
    END IF;

    /* الحصول على معلومات المنتج */
    SELECT price, seller_id
    INTO v_price, v_seller_id
    FROM products
    WHERE id = p_product_id
      AND status = 'active'
    FOR UPDATE;

    /* التحقق من وجود المنتج */
    IF v_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found or inactive';
    END IF;

    /* تقليل المخزون فقط إذا كانت الكمية كافية */
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE id = p_product_id
      AND status = 'active'
      AND stock_quantity >= p_quantity;

    /* عدد الصفوف المتأثرة */
    SET v_rows = ROW_COUNT();

    /* إذا كان المخزون غير كافٍ تتوقف العملية */
    IF v_rows <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    /* تحديث حالة المنتج إذا أصبح المخزون صفرًا */
    UPDATE products
    SET status = 'out_of_stock'
    WHERE id = p_product_id
      AND stock_quantity = 0;

    /* Customer فعال؟ */
    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE id = p_customer_id
          AND status = 'active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer is not active';
    END IF;

    /* Order number */
    SET v_order_number = CONCAT('ORD-', UUID());

    /* إنشاء Order */
    INSERT INTO orders
    (
        order_number,
        customer_id,
        subtotal,
        discount_amount,
        shipping_cost,
        total_amount,
        status
    )
    VALUES
    (
        v_order_number,
        p_customer_id,
        v_price * p_quantity,
        0,
        0,
        v_price * p_quantity,
        'pending'
    );

    SET v_order_id = LAST_INSERT_ID();

    /* إنشاء Order Item */
    INSERT INTO order_items
    (
        order_id,
        product_id,
        seller_id,
        quantity,
        unit_price,
        discount_amount,
        platform_commission,
        seller_amount,
        status
    )
    VALUES
    (
        v_order_id,
        p_product_id,
        v_seller_id,
        p_quantity,
        v_price,
        0,
        0,
        v_price * p_quantity,
        'active'
    );

    COMMIT;

    SELECT
        v_order_id AS order_id,
        v_order_number AS order_number,
        p_product_id AS product_id,
        p_quantity AS quantity;

END$$

DELIMITER ;


-- Coupon Concurrency Challenge



DROP PROCEDURE IF EXISTS use_coupon_safe;

DELIMITER $$

CREATE PROCEDURE use_coupon_safe(
    IN p_coupon_id INT
)
BEGIN
    DECLARE v_used_count INT DEFAULT NULL;
    DECLARE v_usage_limit INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Coupon satırını kilitle
    SELECT used_count, usage_limit
    INTO v_used_count, v_usage_limit
    FROM coupons
    WHERE id = p_coupon_id
    FOR UPDATE;

    -- Coupon mevcut mu?
    IF v_used_count IS NULL OR v_usage_limit IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coupon not found';
    END IF;

    -- Kullanım hakkı kaldı mı?
    IF v_used_count >= v_usage_limit THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coupon usage limit reached';
    END IF;

    -- Kullanım sayısını artır
    UPDATE coupons
    SET used_count = used_count + 1
    WHERE id = p_coupon_id;

    COMMIT;

    SELECT
        p_coupon_id AS coupon_id,
        v_used_count + 1 AS new_used_count;

END$$

DELIMITER ;









-- Idempotency

ALTER TABLE payments
ADD COLUMN idempotency_key VARCHAR(150) NULL,
ADD UNIQUE KEY uq_payment_idempotency (idempotency_key);


DROP PROCEDURE IF EXISTS create_payment;

DELIMITER $$

CREATE PROCEDURE create_payment(
    IN p_order_id INT,
    IN p_amount DECIMAL(12,2),
    IN p_method VARCHAR(20),
    IN p_idempotency_key VARCHAR(150)
)
BEGIN
    DECLARE v_payment_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* Aynı request daha önce geldiyse eski payment'ı döndür */
    SELECT id
    INTO v_payment_id
    FROM payments
    WHERE idempotency_key = p_idempotency_key
    LIMIT 1
    FOR UPDATE;

    IF v_payment_id IS NOT NULL THEN

        COMMIT;

        SELECT
            id,
            order_id,
            amount,
            payment_method,
            status,
            idempotency_key
        FROM payments
        WHERE id = v_payment_id;

    ELSE

        /* Yeni payment oluştur */
        INSERT INTO payments
        (
            order_id,
            payment_reference,
            amount,
            payment_method,
            status,
            idempotency_key
        )
        VALUES
        (
            p_order_id,
            UUID(),
            p_amount,
            p_method,
            'paid',
            p_idempotency_key
        );

        SET v_payment_id = LAST_INSERT_ID();

        COMMIT;

        SELECT
            id,
            order_id,
            amount,
            payment_method,
            status,
            idempotency_key
        FROM payments
        WHERE id = v_payment_id;

    END IF;

END$$

DELIMITER ;





SELECT *
FROM payments
WHERE idempotency_key = 'PAYMENT-ABC-001';



SELECT
    idempotency_key,
    COUNT(*) AS payment_count
FROM payments
WHERE idempotency_key = 'PAYMENT-ABC-001'
GROUP BY idempotency_key;





DROP PROCEDURE IF EXISTS request_return;

DELIMITER $$

CREATE PROCEDURE request_return(
    IN p_order_item_id INT,
    IN p_quantity INT,
    IN p_reason VARCHAR(500)
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_original_quantity INT;
    DECLARE v_returned_quantity INT DEFAULT 0;
    DECLARE v_order_status VARCHAR(30);
    DECLARE v_ordered_at DATETIME;


    SELECT 
        oi.order_id,
        oi.quantity,
        o.status,
        o.ordered_at
    INTO
        v_order_id,
        v_original_quantity,
        v_order_status,
        v_ordered_at
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    WHERE oi.id = p_order_item_id
    LIMIT 1;

    IF v_order_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order Item bulunamadi.';
    END IF;


    IF v_order_status <> 'delivered' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sadece teslim edilmis siparisler iade edilebilir.';
    END IF;


    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Iade miktari 0 dan buyuk olmali.';
    END IF;


    SELECT COALESCE(SUM(quantity), 0)
    INTO v_returned_quantity
    FROM returns
    WHERE order_item_id = p_order_item_id
      AND status IN ('requested', 'approved', 'completed');


    IF v_returned_quantity + p_quantity > v_original_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Toplam iade miktari satin alinan miktari asamaz.';
    END IF;


    IF NOW() > DATE_ADD(v_ordered_at, INTERVAL 30 DAY) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Iade suresi dolmus.';
    END IF;


    INSERT INTO returns
    (
        order_item_id,
        quantity,
        reason,
        status
    )
    VALUES
    (
        p_order_item_id,
        p_quantity,
        p_reason,
        'requested'
    );


    SELECT
        id,
        order_item_id,
        quantity,
        reason,
        requested_at,
        status
    FROM returns
    WHERE id = LAST_INSERT_ID();

END$$

DELIMITER ;


-- Complete Return


DROP PROCEDURE IF EXISTS complete_return;

DELIMITER $$

CREATE PROCEDURE complete_return(
    IN p_return_id INT,
    IN p_payment_id INT
)
BEGIN
    DECLARE v_order_item_id INT;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_unit_price DECIMAL(12,2);
    DECLARE v_return_status VARCHAR(30);
    DECLARE v_refund_amount DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT
        r.order_item_id,
        r.quantity,
        r.status,
        oi.product_id,
        oi.unit_price
    INTO
        v_order_item_id,
        v_quantity,
        v_return_status,
        v_product_id,
        v_unit_price
    FROM returns r
    JOIN order_items oi
        ON oi.id = r.order_item_id
    WHERE r.id = p_return_id
    FOR UPDATE;

    IF v_order_item_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Return bulunamadi';
    END IF;

    IF v_return_status <> 'approved' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Return approved degil';
    END IF;

    
    SET v_refund_amount = v_unit_price * v_quantity;

    UPDATE returns
    SET
        status = 'completed',
        completed_at = NOW()
    WHERE id = p_return_id;

    INSERT INTO refunds
    (
        return_id,
        payment_id,
        amount,
        refunded_at,
        status
    )
    VALUES
    (
        p_return_id,
        p_payment_id,
        v_refund_amount,
        NOW(),
        'completed'
    );

    
    UPDATE payments
    SET status =
        CASE
        WHEN amount <= v_refund_amount
         THEN 'refunded'
        ELSE 'partially_refunded'
        END
    WHERE id = p_payment_id;

    
    UPDATE products
    SET
        stock_quantity = stock_quantity + v_quantity,
        status = CASE
            WHEN status = 'out_of_stock'
                THEN 'active'
            ELSE status
        END
    WHERE id = v_product_id
      AND status IN ('active', 'out_of_stock');

   
    UPDATE orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    SET o.status =
        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM order_items x
                WHERE x.order_id = o.id
                  AND x.id NOT IN (
                      SELECT order_item_id
                      FROM returns
                      WHERE status = 'completed'
                  )
            )
            THEN 'returned'
            ELSE 'partially_returned'
        END
    WHERE oi.id = v_order_item_id;

    COMMIT;

    SELECT
        p_return_id AS return_id,
        v_refund_amount AS refund_amount,
        'completed' AS return_status;

END$$

DELIMITER ;




DROP PROCEDURE IF EXISTS complete_return;

DELIMITER $$

CREATE PROCEDURE complete_return(
    IN p_return_id INT,
    IN p_payment_id INT
)
BEGIN
    DECLARE v_order_item_id INT;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_unit_price DECIMAL(12,2);
    DECLARE v_return_status VARCHAR(30);
    DECLARE v_refund_amount DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT
        r.order_item_id,
        r.quantity,
        r.status,
        oi.product_id,
        oi.unit_price
    INTO
        v_order_item_id,
        v_quantity,
        v_return_status,
        v_product_id,
        v_unit_price
    FROM returns r
    JOIN order_items oi
        ON oi.id = r.order_item_id
    WHERE r.id = p_return_id
    FOR UPDATE;

    IF v_order_item_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Return bulunamadi';
    END IF;

    IF v_return_status <> 'approved' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Return approved degil';
    END IF;

    SET v_refund_amount = v_unit_price * v_quantity;

    UPDATE returns
    SET
        status = 'completed',
        completed_at = NOW()
    WHERE id = p_return_id;

    INSERT INTO refunds
    (
        return_id,
        payment_id,
        amount,
        refunded_at,
        status
    )
    VALUES
    (
        p_return_id,
        p_payment_id,
        v_refund_amount,
        NOW(),
        'completed'
    );

    UPDATE payments
    SET status =
        CASE
        WHEN (
            SELECT COALESCE(SUM(rf.amount), 0)
            FROM refunds rf
            WHERE rf.payment_id = payments.id
              AND rf.status = 'completed'
        ) >= payments.amount
         THEN 'refunded'
        ELSE 'partially_refunded'
        END
    WHERE id = p_payment_id;

    UPDATE products
    SET
        stock_quantity = stock_quantity + v_quantity,
        status = CASE
            WHEN status = 'out_of_stock'
                THEN 'active'
            ELSE status
        END
    WHERE id = v_product_id
      AND status IN ('active', 'out_of_stock');

    UPDATE orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    SET o.status =
        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM order_items x
                WHERE x.order_id = o.id
                  AND (
                      SELECT COALESCE(SUM(r2.quantity), 0)
                      FROM returns r2
                      WHERE r2.order_item_id = x.id
                        AND r2.status = 'completed'
                  ) < x.quantity
            )
            THEN 'returned'
            ELSE 'partially_returned'
        END
    WHERE oi.id = v_order_item_id;

    COMMIT;

    SELECT
        p_return_id AS return_id,
        v_refund_amount AS refund_amount,
        'completed' AS return_status;

END$$

DELIMITER ;



-- Financial Integrity


SELECT
    o.id,
    o.order_number,
    o.total_amount,
    ROUND(
        COALESCE(SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ), 0)
        - o.discount_amount
        + o.shipping_cost,
        2
    ) AS calculated_total
FROM orders o
LEFT JOIN order_items oi
    ON oi.order_id = o.id
GROUP BY
    o.id,
    o.order_number,
    o.total_amount,
    o.discount_amount,
    o.shipping_cost
HAVING o.total_amount <> calculated_total;



SELECT
    oi.id,
    oi.order_id,
    oi.seller_id,
    oi.seller_amount,
    ROUND(
        (
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) - oi.platform_commission,
        2
    ) AS expected_seller_amount
FROM order_items oi
WHERE oi.seller_amount <>
      ROUND(
          (
              oi.quantity * oi.unit_price
              - oi.discount_amount
          ) - oi.platform_commission,
          2
      );



SELECT
    oi.id,
    oi.seller_id,
    oi.platform_commission,
    s.commission_rate,
    ROUND(
        (
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) * s.commission_rate / 100,
        2
    ) AS expected_commission
FROM order_items oi
JOIN sellers s
    ON s.id = oi.seller_id
WHERE oi.platform_commission <>
      ROUND(
          (
              oi.quantity * oi.unit_price
              - oi.discount_amount
          ) * s.commission_rate / 100,
          2
      );




SELECT
    o.id,
    o.order_number,
    o.total_amount,
    SUM(
        CASE
            WHEN p.status IN ('paid', 'partially_refunded', 'refunded')
            THEN p.amount
            ELSE 0
        END
    ) AS payment_total
FROM orders o
JOIN payments p
    ON p.order_id = o.id
GROUP BY
    o.id,
    o.order_number,
    o.total_amount
HAVING payment_total > o.total_amount;




SELECT
    p.id AS payment_id,
    p.amount AS payment_amount,
    COALESCE(SUM(r.amount), 0) AS refund_amount
FROM payments p
LEFT JOIN refunds r
    ON r.payment_id = p.id
GROUP BY
    p.id,
    p.amount
HAVING refund_amount > payment_amount;




SELECT
    oi.id AS order_item_id,
    oi.quantity AS purchased_quantity,
    COALESCE(SUM(r.quantity), 0) AS returned_quantity
FROM order_items oi
LEFT JOIN returns r
    ON r.order_item_id = oi.id
   AND r.status IN ('approved', 'completed')
GROUP BY
    oi.id,
    oi.quantity
HAVING returned_quantity > purchased_quantity;




SELECT
    id,
    product_name,
    stock_quantity
FROM products
WHERE stock_quantity < 0;



SELECT
    ss.id,
    ss.seller_id,
    ss.period_start,
    ss.period_end,
    ss.net_amount AS settlement_amount,

    COALESCE(SUM(oi.seller_amount), 0)
    - ss.refund_amount AS actual_amount

FROM seller_settlements ss

LEFT JOIN order_items oi
    ON oi.seller_id = ss.seller_id
   AND EXISTS (
       SELECT 1
       FROM orders o
       WHERE o.id = oi.order_id
         AND DATE(o.ordered_at)
             BETWEEN ss.period_start AND ss.period_end
   )

GROUP BY
    ss.id,
    ss.seller_id,
    ss.period_start,
    ss.period_end,
    ss.net_amount,
    ss.refund_amount

HAVING ss.net_amount <>
       (
           COALESCE(SUM(oi.seller_amount), 0)
           - ss.refund_amount
       );






-- Window Functions


SELECT
    p.id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue,

    ROW_NUMBER() OVER (
        ORDER BY
            SUM(oi.quantity * oi.unit_price - oi.discount_amount) DESC
    ) AS revenue_row

FROM products p
JOIN order_items oi
    ON oi.product_id = p.id
JOIN orders o
    ON o.id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY
    p.id,
    p.product_name;




SELECT
    p.category_id,
    p.id,
    p.product_name,

    SUM(
        oi.quantity * oi.unit_price
        - oi.discount_amount
    ) AS revenue,

    RANK() OVER (
        PARTITION BY p.category_id
        ORDER BY
            SUM(
                oi.quantity * oi.unit_price
                - oi.discount_amount
            ) DESC
    ) AS category_rank

FROM products p
JOIN order_items oi
    ON oi.product_id = p.id
JOIN orders o
    ON o.id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY
    p.category_id,
    p.id,
    p.product_name;





WITH ranked_products AS
(
    SELECT
        p.category_id,
        p.id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue,

        DENSE_RANK() OVER (
            PARTITION BY p.category_id
            ORDER BY
                SUM(
                    oi.quantity * oi.unit_price
                    - oi.discount_amount
                ) DESC
        ) AS rnk

    FROM products p
    JOIN order_items oi
        ON oi.product_id = p.id
    JOIN orders o
        ON o.id = oi.order_id
    WHERE o.status <> 'cancelled'

    GROUP BY
        p.category_id,
        p.id,
        p.product_name
)

SELECT *
FROM ranked_products
WHERE rnk <= 3;




SELECT
    s.id,
    s.store_name,

    SUM(
        oi.quantity * oi.unit_price
        - oi.discount_amount
    ) AS revenue,

    ROW_NUMBER() OVER (
        ORDER BY
            SUM(
                oi.quantity * oi.unit_price
                - oi.discount_amount
            ) DESC
    ) AS revenue_rank

FROM sellers s
JOIN order_items oi
    ON oi.seller_id = s.id
JOIN orders o
    ON o.id = oi.order_id
WHERE o.status <> 'cancelled'

GROUP BY
    s.id,
    s.store_name;





SELECT
    product_id,
    changed_at,
    old_price,
    new_price,

    LAG(new_price) OVER (
        PARTITION BY product_id
        ORDER BY changed_at
    ) AS previous_price

FROM product_price_history;





SELECT
    product_id,
    changed_at,
    old_price,
    new_price,

    LAG(new_price) OVER (
        PARTITION BY product_id
        ORDER BY changed_at
    ) AS previous_price,

    ROUND(
        (
            new_price
            -
            LAG(new_price) OVER (
                PARTITION BY product_id
                ORDER BY changed_at
            )
        )
        /
        NULLIF(
            LAG(new_price) OVER (
                PARTITION BY product_id
                ORDER BY changed_at
            ),
            0
        ) * 100,
        2
    ) AS change_percent

FROM product_price_history;





WITH monthly AS
(
    SELECT
        DATE_FORMAT(o.ordered_at, '%Y-%m') AS month,
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    WHERE o.status <> 'cancelled'
    GROUP BY
        DATE_FORMAT(o.ordered_at, '%Y-%m')
)

SELECT
    month,
    revenue,

    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,

    revenue -
    LAG(revenue) OVER (
        ORDER BY month
    ) AS revenue_difference

FROM monthly
ORDER BY month;






WITH daily AS
(
    SELECT
        DATE(o.ordered_at) AS order_date,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue

    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id

    WHERE o.status <> 'cancelled'

    GROUP BY DATE(o.ordered_at)
)

SELECT
    order_date,
    revenue,

    SUM(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_revenue

FROM daily
ORDER BY order_date;





WITH seller_daily AS
(
    SELECT
        oi.seller_id,
        DATE(o.ordered_at) AS sale_date,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue

    FROM order_items oi
    JOIN orders o
        ON o.id = oi.order_id

    WHERE o.status <> 'cancelled'

    GROUP BY
        oi.seller_id,
        DATE(o.ordered_at)
)

SELECT
    seller_id,
    sale_date,
    revenue,

    SUM(revenue) OVER (
        PARTITION BY seller_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_seller_revenue

FROM seller_daily
ORDER BY
    seller_id,
    sale_date;




SELECT
    c.id,
    c.full_name,

    SUM(o.total_amount) AS spending,

    DENSE_RANK() OVER (
        ORDER BY SUM(o.total_amount) DESC
    ) AS spending_rank

FROM customers c
JOIN orders o
    ON o.customer_id = c.id

WHERE o.status <> 'cancelled'

GROUP BY
    c.id,
    c.full_name;






WITH ranked_orders AS
(
    SELECT
        o.*,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY ordered_at DESC
        ) AS rn

    FROM orders o
    WHERE o.status <> 'cancelled'
)

SELECT *
FROM ranked_orders
WHERE rn = 1;














-- CTE


WITH customer_spending AS
(
    SELECT
        c.id AS customer_id,
        c.full_name,

        COUNT(o.id) AS order_count,

        COALESCE(SUM(o.total_amount), 0) AS total_spending

    FROM customers c
    LEFT JOIN orders o
        ON o.customer_id = c.id
       AND o.status <> 'cancelled'

    GROUP BY
        c.id,
        c.full_name
)

SELECT *
FROM customer_spending
ORDER BY total_spending DESC;




WITH seller_sales AS
(
    SELECT
        s.id AS seller_id,
        s.store_name,

        COUNT(DISTINCT oi.order_id) AS order_count,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue,

        SUM(oi.platform_commission) AS commission,

        SUM(oi.seller_amount) AS seller_earnings

    FROM sellers s
    JOIN order_items oi
        ON oi.seller_id = s.id

    JOIN orders o
        ON o.id = oi.order_id
       AND o.status <> 'cancelled'

    GROUP BY
        s.id,
        s.store_name
)

SELECT *
FROM seller_sales
ORDER BY revenue DESC;




WITH product_sales AS
(
    SELECT
        p.id AS product_id,
        p.product_name,

        SUM(oi.quantity) AS units_sold,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue

    FROM products p
    JOIN order_items oi
        ON oi.product_id = p.id

    JOIN orders o
        ON o.id = oi.order_id
       AND o.status <> 'cancelled'

    GROUP BY
        p.id,
        p.product_name
)

SELECT *
FROM product_sales
ORDER BY revenue DESC;




WITH monthly_revenue AS
(
    SELECT
        DATE_FORMAT(o.ordered_at, '%Y-%m') AS month,

        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS revenue,

        COUNT(DISTINCT o.id) AS order_count

    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id

    WHERE o.status <> 'cancelled'

    GROUP BY
        DATE_FORMAT(o.ordered_at, '%Y-%m')
)

SELECT *
FROM monthly_revenue
ORDER BY month;




WITH return_data AS
(
    SELECT
        r.id AS return_id,
        r.order_item_id,
        r.quantity,
        r.status,
        r.requested_at,

        oi.product_id,
        oi.unit_price,

        r.quantity * oi.unit_price AS refund_value

    FROM returns r
    JOIN order_items oi
        ON oi.id = r.order_item_id
)

SELECT
    return_id,
    order_item_id,
    product_id,
    quantity,
    refund_value,
    status,
    requested_at
FROM return_data
ORDER BY requested_at DESC;





WITH inventory AS
(
    SELECT
        p.id AS product_id,
        p.product_name,
        p.stock_quantity,
        p.minimum_stock,

        CASE
            WHEN p.stock_quantity = 0
                THEN 'OUT_OF_STOCK'

            WHEN p.stock_quantity <= p.minimum_stock
                THEN 'LOW_STOCK'

            ELSE 'NORMAL'
        END AS stock_status

    FROM products p
)

SELECT *
FROM inventory
ORDER BY stock_quantity;






WITH coupon_performance AS
(
    SELECT
        c.id,
        c.code,
        c.usage_limit,
        c.used_count,

        COUNT(o.id) AS order_count,

        COALESCE(SUM(o.discount_amount), 0)
            AS total_discount

    FROM coupons c

    LEFT JOIN orders o
        ON o.coupon_id = c.id
       AND o.status <> 'cancelled'

    GROUP BY
        c.id,
        c.code,
        c.usage_limit,
        c.used_count
)

SELECT
    *,
    ROUND(
        used_count / NULLIF(usage_limit, 0) * 100,
        2
    ) AS usage_percent
FROM coupon_performance
ORDER BY used_count DESC;






-- Seller Settlements


CREATE TABLE seller_settlement_items (
    id INT AUTO_INCREMENT PRIMARY KEY,

    settlement_id INT NOT NULL,
    order_item_id INT NOT NULL,

    seller_id INT NOT NULL,
    gross_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    commission_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    refund_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    net_amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    FOREIGN KEY (settlement_id)
        REFERENCES seller_settlements(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (order_item_id)
        REFERENCES order_items(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (seller_id)
        REFERENCES sellers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    UNIQUE KEY uq_settlement_order_item (order_item_id),

    INDEX idx_settlement_seller (seller_id),
    INDEX idx_settlement_id (settlement_id)
);


INSERT INTO seller_settlement_items
(
    settlement_id,
    order_item_id,
    seller_id,
    gross_amount,
    commission_amount,
    refund_amount,
    net_amount
)
VALUES
(1, 1, 1, 500.00, 50.00, 0.00, 450.00),
(1, 2, 1, 750.00, 75.00, 50.00, 625.00),
(2, 3, 2, 900.00, 90.00, 0.00, 810.00),
(2, 4, 2, 450.00, 45.00, 25.00, 380.00),
(3, 5, 3, 1200.00, 120.00, 100.00, 980.00),
(3, 6, 3, 650.00, 65.00, 0.00, 585.00),
(4, 7, 4, 800.00, 80.00, 50.00, 670.00),
(5, 8, 5, 1500.00, 150.00, 200.00, 1150.00),
(6, 9, 6, 950.00, 95.00, 0.00, 855.00),
(7, 10, 7, 1100.00, 110.00, 75.00, 915.00);



DELIMITER $$

DROP PROCEDURE IF EXISTS generate_seller_settlement$$

CREATE PROCEDURE generate_seller_settlement(
    IN p_seller_id INT,
    IN p_period_start DATE,
    IN p_period_end DATE
)
BEGIN

    DECLARE v_settlement_id INT DEFAULT NULL;
    DECLARE v_gross_sales DECIMAL(12,2) DEFAULT 0;
    DECLARE v_commission DECIMAL(12,2) DEFAULT 0;
    DECLARE v_refunds DECIMAL(12,2) DEFAULT 0;
    DECLARE v_net_amount DECIMAL(12,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* Tarih kontrolü */
    IF p_period_end < p_period_start THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'period_end cannot be before period_start';
    END IF;

    /* Seller kontrolü ve kilitleme */
    IF NOT EXISTS (
        SELECT 1
        FROM sellers
        WHERE id = p_seller_id
        FOR UPDATE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seller does not exist';
    END IF;

    /* Aynı seller + dönem daha önce oluşturulmuş mu? */
    SELECT id
    INTO v_settlement_id
    FROM seller_settlements
    WHERE seller_id = p_seller_id
      AND period_start = p_period_start
      AND period_end = p_period_end
    FOR UPDATE;

    IF v_settlement_id IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Settlement for this seller and period already exists';

    END IF;



    SELECT
        COALESCE(
            SUM(oi.quantity * oi.unit_price - oi.discount_amount),
            0
        ),
        COALESCE(
            SUM(oi.platform_commission),
            0
        )
    INTO
        v_gross_sales,
        v_commission
    FROM order_items oi
    JOIN orders o
        ON o.id = oi.order_id
    WHERE oi.seller_id = p_seller_id
      AND o.status IN ('delivered', 'partially_returned', 'returned')
      AND o.ordered_at >= p_period_start
      AND o.ordered_at < DATE_ADD(p_period_end, INTERVAL 1 DAY)
      AND EXISTS (
          SELECT 1
          FROM payments p
          WHERE p.order_id = o.id
            AND p.status IN ('paid', 'partially_refunded', 'refunded')
      )
      AND NOT EXISTS (
          SELECT 1
          FROM seller_settlement_items ssi
          WHERE ssi.order_item_id = oi.id
      );

    /*
       Refund toplamı
    */

    SELECT
        COALESCE(SUM(rf.amount), 0)
    INTO v_refunds
    FROM refunds rf
    JOIN returns r
        ON r.id = rf.return_id
    JOIN order_items oi
        ON oi.id = r.order_item_id
    JOIN orders o
        ON o.id = oi.order_id
    WHERE oi.seller_id = p_seller_id
      AND o.status IN ('delivered', 'partially_returned', 'returned')
      AND o.ordered_at >= p_period_start
      AND o.ordered_at < DATE_ADD(p_period_end, INTERVAL 1 DAY)
      AND r.status = 'completed'
      AND NOT EXISTS (
          SELECT 1
          FROM seller_settlement_items ssi
          WHERE ssi.order_item_id = oi.id
      );

    SET v_net_amount =
        v_gross_sales
        - v_commission
        - v_refunds;

    IF v_net_amount < 0 THEN
        SET v_net_amount = 0;
    END IF;

    /*
       Settlement oluştur
    */

    INSERT INTO seller_settlements
    (
        seller_id,
        period_start,
        period_end,
        gross_sales,
        commission_amount,
        refund_amount,
        net_amount,
        status
    )
    VALUES
    (
        p_seller_id,
        p_period_start,
        p_period_end,
        v_gross_sales,
        v_commission,
        v_refunds,
        v_net_amount,
        'pending'
    );

    SET v_settlement_id = LAST_INSERT_ID();

    /*
       Settlement'a Order Items ekle
    */

    INSERT INTO seller_settlement_items
    (
        settlement_id,
        order_item_id,
        seller_id,
        gross_amount,
        commission_amount,
        refund_amount,
        net_amount
    )
    SELECT
        v_settlement_id,
        oi.id,
        oi.seller_id,

        oi.quantity * oi.unit_price
        - oi.discount_amount,

        oi.platform_commission,

        COALESCE(
            (
                SELECT SUM(rf.amount)
                FROM refunds rf
                JOIN returns r
                    ON r.id = rf.return_id
                WHERE r.order_item_id = oi.id
                  AND r.status = 'completed'
            ),
            0
        ),

        (
            oi.quantity * oi.unit_price
            - oi.discount_amount
            - oi.platform_commission
            - COALESCE(
                (
                    SELECT SUM(rf.amount)
                    FROM refunds rf
                    JOIN returns r
                        ON r.id = rf.return_id
                    WHERE r.order_item_id = oi.id
                      AND r.status = 'completed'
                ),
                0
            )
        )

    FROM order_items oi

    JOIN orders o
        ON o.id = oi.order_id

    WHERE oi.seller_id = p_seller_id
      AND o.status IN ('delivered', 'partially_returned', 'returned')
      AND o.ordered_at >= p_period_start
      AND o.ordered_at < DATE_ADD(p_period_end, INTERVAL 1 DAY)

      AND EXISTS (
          SELECT 1
          FROM payments p
          WHERE p.order_id = o.id
            AND p.status IN ('paid', 'partially_refunded', 'refunded')
      )

      AND NOT EXISTS (
          SELECT 1
          FROM seller_settlement_items ssi
          WHERE ssi.order_item_id = oi.id
      );

    COMMIT;

    /*
       Oluşturulan settlement'ı göster
    */

    SELECT *
    FROM seller_settlements
    WHERE id = v_settlement_id;

END$$

DELIMITER ;










-- Reviews Integrity


DELIMITER $$

DROP PROCEDURE IF EXISTS create_review$$

CREATE PROCEDURE create_review(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_order_item_id INT,
    IN p_rating INT,
    IN p_comment TEXT
)
BEGIN

    DECLARE v_order_id INT DEFAULT NULL;
    DECLARE v_item_product_id INT;
    DECLARE v_order_customer_id INT;
    DECLARE v_order_status VARCHAR(30);

    /* Rating kontrolü */
    IF p_rating < 1 OR p_rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;

    /* Order Item bilgilerini al */
    SELECT
        oi.order_id,
        oi.product_id,
        o.customer_id,
        o.status
    INTO
        v_order_id,
        v_item_product_id,
        v_order_customer_id,
        v_order_status
    FROM order_items oi
    JOIN orders o
        ON o.id = oi.order_id
    WHERE oi.id = p_order_item_id;

    /* Order Item var mı? */
    IF v_order_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order item does not exist';
    END IF;

    /* Customer gerçekten bu order'ın sahibi mi? */
    IF v_order_customer_id <> p_customer_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer did not purchase this item';
    END IF;

    /* Product gerçekten Order Item'a ait mi? */
    IF v_item_product_id <> p_product_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product does not belong to this order item';
    END IF;

    /* Order delivered olmalı */
    IF v_order_status <> 'delivered' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only delivered orders can be reviewed';
    END IF;

    /* Daha önce review var mı? */
    IF EXISTS (
        SELECT 1
        FROM reviews
        WHERE customer_id = p_customer_id
          AND order_item_id = p_order_item_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer already reviewed this order item';
    END IF;

    /* Review oluştur */
    INSERT INTO reviews
    (
        customer_id,
        product_id,
        order_item_id,
        rating,
        comment,
        status
    )
    VALUES
    (
        p_customer_id,
        p_product_id,
        p_order_item_id,
        p_rating,
        p_comment,
        'active'
    );

END$$

DELIMITER ;






-- Price History Trigger


DELIMITER $$

DROP TRIGGER IF EXISTS trg_product_price_history$$

CREATE TRIGGER trg_product_price_history
AFTER UPDATE ON products
FOR EACH ROW
BEGIN

    IF NOT (OLD.price <=> NEW.price) THEN

        INSERT INTO product_price_history
        (
            product_id,
            old_price,
            new_price,
            changed_at
        )
        VALUES
        (
            NEW.id,
            OLD.price,
            NEW.price,
            NOW()
        );

    END IF;

END$$

DELIMITER ;




SELECT id, product_name, price
FROM products
WHERE id = 1;





UPDATE products
SET price = price + 100
WHERE id = 1;



UPDATE products
SET price = price + 100
WHERE id = 1;



-- Query Optimization Challenge

CREATE TABLE seller_performance_summary (
    seller_id INT PRIMARY KEY,

    total_orders BIGINT NOT NULL DEFAULT 0,
    products_sold BIGINT NOT NULL DEFAULT 0,

    revenue DECIMAL(14,2) NOT NULL DEFAULT 0,
    commission DECIMAL(14,2) NOT NULL DEFAULT 0,
    refunds DECIMAL(14,2) NOT NULL DEFAULT 0,
    net_revenue DECIMAL(14,2) NOT NULL DEFAULT 0,

    unique_customers BIGINT NOT NULL DEFAULT 0,

    average_rating DECIMAL(5,2) NULL,

    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id)
        REFERENCES sellers(id)
);



INSERT INTO seller_performance_summary
(
    seller_id,
    total_orders,
    products_sold,
    revenue,
    commission,
    refunds,
    net_revenue,
    unique_customers,
    average_rating,
    last_updated
)
VALUES
(1, 45, 120, 18500.00, 1850.00, 450.00, 16200.00, 38, 4.72, '2026-09-30 10:00:00'),
(2, 32, 85, 12400.00, 1240.00, 300.00, 10860.00, 28, 4.55, '2026-09-30 10:05:00'),
(3, 67, 190, 27600.00, 2760.00, 720.00, 24120.00, 54, 4.81, '2026-09-30 10:10:00'),
(4, 28, 64, 8900.00, 890.00, 150.00, 7860.00, 24, 4.30, '2026-09-30 10:15:00'),
(5, 51, 140, 21300.00, 2130.00, 510.00, 18660.00, 43, 4.65, '2026-09-30 10:20:00'),
(6, 39, 97, 14600.00, 1460.00, 280.00, 12860.00, 33, 4.42, '2026-09-30 10:25:00'),
(7, 73, 215, 32400.00, 3240.00, 850.00, 28310.00, 61, 4.90, '2026-09-30 10:30:00'),
(8, 24, 58, 7600.00, 760.00, 120.00, 6720.00, 21, 4.18, '2026-09-30 10:35:00'),
(9, 56, 155, 23800.00, 2380.00, 600.00, 20820.00, 47, 4.76, '2026-09-30 10:40:00'),
(10, 41, 108, 15900.00, 1590.00, 350.00, 13960.00, 35, 4.51, '2026-09-30 10:45:00');




SELECT
    s.store_name AS seller,
    sp.total_orders AS orders,
    sp.products_sold,
    sp.revenue,
    sp.commission,
    sp.refunds,
    sp.net_revenue,
    sp.unique_customers,
    sp.average_rating
FROM seller_performance_summary sp
JOIN sellers s
    ON s.id = sp.seller_id
ORDER BY sp.net_revenue DESC;



TRUNCATE TABLE seller_performance_summary;









-- Partitioning-


SELECT *
FROM orders
WHERE ordered_at >= '2026-01-01'
  AND ordered_at < '2027-01-01';




SELECT *
FROM orders
WHERE customer_id = 10;




SELECT *
FROM orders
WHERE customer_id = 10
  AND ordered_at >= '2026-01-01'
  AND ordered_at < '2027-01-01';






-- Isolation Levels


-- Block 1: uncommitted write (demo) — نتراجع عنه حتى لا يلوث البيانات
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

UPDATE products
SET stock_quantity = 0
WHERE id = 10;

ROLLBACK;                       





-- Block 2
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

SELECT stock_quantity
FROM products
WHERE id = 10;

COMMIT;                            





-- Block 3
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT stock_quantity
FROM products
WHERE id = 10;

COMMIT;                            





START TRANSACTION;

UPDATE products
SET stock_quantity = 8
WHERE id = 10;

COMMIT;                            





SELECT stock_quantity
FROM products
WHERE id = 10;





START TRANSACTION;

SELECT COUNT(*)
FROM orders
WHERE status = 'pending';

COMMIT;                            




START TRANSACTION;

SELECT stock_quantity
FROM products
WHERE id = 10;

COMMIT;                            




UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE id = 10
  AND stock_quantity >= 1;



-- Savepoint


START TRANSACTION;

INSERT INTO order_items
(
    order_id,
    product_id,
    seller_id,
    quantity,
    unit_price,
    discount_amount,
    platform_commission,
    seller_amount
)
VALUES
(1, 10, 1, 2, 100, 0, 10, 190);

SAVEPOINT seller1_done;


INSERT INTO order_items
(
    order_id,
    product_id,
    seller_id,
    quantity,
    unit_price,
    discount_amount,
    platform_commission,
    seller_amount
)
VALUES
(1, 20, 2, 1, 200, 0, 20, 180);

ROLLBACK TO SAVEPOINT seller1_done;   

ROLLBACK;                             



-- Data Integrity Challenge-



SELECT id, product_name, stock_quantity
FROM products
WHERE stock_quantity < 0;



UPDATE products
SET stock_quantity = stock_quantity - 2
WHERE id = 1
  AND stock_quantity >= 2;



SELECT id, code
FROM coupons
WHERE id = 1
  AND status = 'active'
  AND starts_at <= NOW()
  AND expires_at > NOW()
  AND used_count < usage_limit;




START TRANSACTION;

UPDATE coupons
SET used_count = used_count + 1
WHERE id = 1
  AND status = 'active'
  AND starts_at <= NOW()
  AND expires_at > NOW()
  AND used_count < usage_limit;
COMMIT;  


DELIMITER //

CREATE PROCEDURE use_coupon(IN p_coupon_id INT)
BEGIN

    START TRANSACTION;

    UPDATE coupons
    SET used_count = used_count + 1
    WHERE id = p_coupon_id
      AND status = 'active'
      AND starts_at <= NOW()
      AND expires_at > NOW()
      AND used_count < usage_limit;

    IF ROW_COUNT() = 1 THEN
        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coupon is not available or usage limit reached';
    END IF;

END//

DELIMITER ;


SELECT
    r.payment_id,
    SUM(r.amount) AS total_refunded,
    p.amount AS payment_amount
FROM refunds r
JOIN payments p
    ON p.id = r.payment_id
GROUP BY r.payment_id, p.amount
HAVING SUM(r.amount) > p.amount;


SELECT
    r.order_item_id,
    oi.quantity AS purchased_quantity,
    SUM(r.quantity) AS returned_quantity
FROM returns r
JOIN order_items oi
    ON oi.id = r.order_item_id
GROUP BY r.order_item_id, oi.quantity
HAVING SUM(r.quantity) > oi.quantity;




SELECT
    r.id,
    r.customer_id,
    r.product_id,
    r.order_item_id
FROM reviews r
JOIN order_items oi
    ON oi.id = r.order_item_id
JOIN orders o
    ON o.id = oi.order_id
WHERE r.customer_id <> o.customer_id;




DELIMITER //

CREATE PROCEDURE add_review(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_order_item_id INT,
    IN p_rating INT,
    IN p_comment TEXT
)
BEGIN

    DECLARE v_customer_id INT;
    DECLARE v_product_id INT;
    DECLARE v_order_status VARCHAR(30);

    SELECT
        o.customer_id,
        oi.product_id,
        o.status
    INTO
        v_customer_id,
        v_product_id,
        v_order_status
    FROM order_items oi
    JOIN orders o
        ON o.id = oi.order_id
    WHERE oi.id = p_order_item_id;

    IF v_customer_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order item does not exist';

    ELSEIF v_customer_id <> p_customer_id THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer did not purchase this product';

    ELSEIF v_product_id <> p_product_id THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product does not match order item';

    ELSEIF v_order_status <> 'delivered' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only delivered orders can be reviewed';

    ELSE

        INSERT INTO reviews
        (
            customer_id,
            product_id,
            order_item_id,
            rating,
            comment
        )
        VALUES
        (
            p_customer_id,
            p_product_id,
            p_order_item_id,
            p_rating,
            p_comment
        );

    END IF;

END//

DELIMITER ;



SELECT
    payment_reference,
    COUNT(*) AS payment_count
FROM payments
GROUP BY payment_reference
HAVING COUNT(*) > 1;



INSERT INTO payments
(
    order_id,
    payment_reference,
    amount,
    payment_method,
    status
)
VALUES
(
    1,
    'PAY-TEST-001',
    100.00,
    'card',
    'paid'
);



SELECT
    seller_id,
    period_start,
    period_end,
    COUNT(*) AS settlement_count
FROM seller_settlements
GROUP BY
    seller_id,
    period_start,
    period_end
HAVING COUNT(*) > 1;




SELECT
    o.id,
    o.order_number
FROM orders o
LEFT JOIN shipments s
    ON s.order_id = o.id
WHERE o.status = 'delivered'
  AND s.id IS NULL;





SELECT
    oi.id,
    oi.order_id,
    oi.product_id,
    p.product_name,
    p.status
FROM order_items oi
JOIN products p
    ON p.id = oi.product_id
WHERE p.status <> 'active';




SELECT id, product_name
FROM products
WHERE id = 1
  AND status = 'active'
  AND stock_quantity >= 1;


SELECT
    oi.id,
    oi.order_id,
    oi.seller_id,
    s.store_name,
    s.status
FROM order_items oi
JOIN sellers s
    ON s.id = oi.seller_id
WHERE s.status <> 'active';



SELECT id, store_name
FROM sellers
WHERE id = 1
  AND status = 'active';





-- NORMALIZATION

CREATE TABLE bad_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    products VARCHAR(500)
);

INSERT INTO bad_orders (order_id, products)
VALUES
(1, 'Laptop, Mouse, Keyboard'),
(2, 'Phone, Charger, Phone Case'),
(3, 'Headphones, Speaker'),
(4, 'Monitor, HDMI Cable, Mouse'),
(5, 'Tablet, Stylus, Tablet Case'),
(6, 'Keyboard, Mouse Pad'),
(7, 'Camera, Memory Card, Tripod'),
(8, 'Smartwatch, Charger'),
(9, 'Laptop, Headphones, USB Cable'),
(10, 'Printer, Ink, Paper');

SELECT
    o.id AS order_id,
    oi.product_id,
    oi.quantity
FROM orders o
JOIN order_items oi
    ON oi.order_id = o.id;

SELECT
    id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    platform_commission,
    seller_amount
FROM order_items;

SELECT
    o.id,
    c.full_name
FROM orders o
JOIN customers c
    ON c.id = o.customer_id;

SELECT
    id,
    full_name,
    email,
    phone,
    registered_at,
    status
FROM customers;

SELECT
    id,
    seller_id,
    category_id,
    sku,
    product_name,
    price,
    cost_price,
    stock_quantity,
    minimum_stock,
    status
FROM products;

SELECT
    p.id AS product_id,
    p.product_name,
    s.id AS seller_id,
    s.store_name,
    s.email
FROM products p
JOIN sellers s
    ON s.id = p.seller_id;

SELECT
    ca.id,
    ca.customer_id,
    ca.title,
    ca.city,
    ca.district,
    ca.street,
    ca.postal_code
FROM customer_addresses ca;

SELECT
    o.order_number,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN order_items oi
    ON oi.order_id = o.id
ORDER BY o.id;

SELECT
    product_id,
    old_price,
    new_price,
    changed_at
FROM product_price_history
ORDER BY product_id, changed_at;

SELECT
    oi.order_id,
    oi.product_id,
    oi.unit_price,
    p.price AS current_price
FROM order_items oi
JOIN products p
    ON p.id = oi.product_id;

SELECT
    r.id AS return_id,
    r.order_item_id,
    r.quantity,
    r.reason,
    r.status
FROM returns r;

SELECT
    rf.id,
    rf.return_id,
    rf.payment_id,
    rf.amount,
    rf.status
FROM refunds rf;

SELECT
    o.id AS order_id,
    o.order_number,
    c.id AS customer_id,
    c.full_name,
    c.email,
    p.id AS product_id,
    p.product_name,
    s.id AS seller_id,
    s.store_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount
FROM orders o
JOIN customers c
    ON c.id = o.customer_id
JOIN order_items oi
    ON oi.order_id = o.id
JOIN products p
    ON p.id = oi.product_id
JOIN sellers s
    ON s.id = oi.seller_id
ORDER BY o.id, oi.id;

SELECT
    email,
    COUNT(*) AS count_email
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

SELECT
    sku,
    COUNT(*) AS count_sku
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;

SELECT
    code,
    COUNT(*) AS count_code
FROM coupons
GROUP BY code
HAVING COUNT(*) > 1;

SELECT
    order_number,
    COUNT(*) AS count_order
FROM orders
GROUP BY order_number
HAVING COUNT(*) > 1;

SELECT
    payment_reference,
    COUNT(*) AS count_reference
FROM payments
GROUP BY payment_reference
HAVING COUNT(*) > 1;

SELECT
    tracking_number,
    COUNT(*) AS count_tracking
FROM shipments
GROUP BY tracking_number
HAVING COUNT(*) > 1;



-- historical data challenge

UPDATE products
SET price = 100
WHERE id = 1;



UPDATE products
SET price = 150
WHERE id = 1;



SELECT
    oi.order_id,
    oi.product_id,
    oi.unit_price AS historical_price,
    p.price AS current_price
FROM order_items oi
JOIN products p
    ON p.id = oi.product_id
WHERE oi.product_id = 1;



SELECT
    oi.order_id,
    oi.platform_commission AS historical_commission_rate,
    s.commission_rate AS current_commission_rate
FROM order_items oi
JOIN sellers s
    ON s.id = oi.seller_id;



SELECT
    oi.order_id,
    oi.product_id,
    oi.unit_price,
    oi.discount_amount
FROM order_items oi;






WITH
product_stats AS
(
    SELECT
        seller_id,
        COUNT(*) AS total_products,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_products,
        COALESCE(SUM(stock_quantity * cost_price), 0) AS current_stock_value
    FROM products
    GROUP BY seller_id
),

sales_stats AS
(
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.quantity) AS total_items_sold,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        ROUND(
            SUM(
                (oi.quantity * oi.unit_price)
                - oi.discount_amount
            ),
            2
        ) AS gross_sales,
        ROUND(SUM(oi.platform_commission), 2) AS total_commission,
        MAX(o.ordered_at) AS last_sale_date
    FROM order_items oi
    JOIN orders o
        ON o.id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY oi.seller_id
),

refund_stats AS
(
    SELECT
        oi.seller_id,
        ROUND(SUM(rf.amount), 2) AS total_refunds
    FROM refunds rf
    JOIN returns r
        ON r.id = rf.return_id
    JOIN order_items oi
        ON oi.id = r.order_item_id
    WHERE rf.status = 'completed'
    GROUP BY oi.seller_id
),

rating_stats AS
(
    SELECT
        p.seller_id,
        ROUND(AVG(rv.rating), 2) AS average_product_rating
    FROM products p
    LEFT JOIN reviews rv
        ON rv.product_id = p.id
    GROUP BY p.seller_id
),

return_stats AS
(
    SELECT
        oi.seller_id,
        SUM(r.quantity) AS returned_quantity
    FROM returns r
    JOIN order_items oi
        ON oi.id = r.order_item_id
    WHERE r.status IN ('approved', 'completed')
    GROUP BY oi.seller_id
),

best_products AS
(
    SELECT
        seller_id,
        product_name,
        ROW_NUMBER() OVER
        (
            PARTITION BY seller_id
            ORDER BY units_sold DESC, product_id
        ) AS rn
    FROM
    (
        SELECT
            oi.seller_id,
            p.id AS product_id,
            p.product_name,
            SUM(oi.quantity) AS units_sold
        FROM order_items oi
        JOIN products p
            ON p.id = oi.product_id
        JOIN orders o
            ON o.id = oi.order_id
        WHERE o.status <> 'cancelled'
        GROUP BY
            oi.seller_id,
            p.id,
            p.product_name
    ) x
)

SELECT
    s.id AS seller_id,
    s.store_name,

    COALESCE(ps.total_products, 0) AS total_products,
    COALESCE(ps.active_products, 0) AS active_products,

    COALESCE(ss.total_orders, 0) AS total_orders,
    COALESCE(ss.total_items_sold, 0) AS total_items_sold,
    COALESCE(ss.unique_customers, 0) AS unique_customers,

    COALESCE(ss.gross_sales, 0) AS gross_sales,
    COALESCE(ss.total_commission, 0) AS total_commission,
    COALESCE(rs.total_refunds, 0) AS total_refunds,

    ROUND(
        COALESCE(ss.gross_sales, 0)
        - COALESCE(ss.total_commission, 0)
        - COALESCE(rs.total_refunds, 0),
        2
    ) AS net_sales,

    CASE
        WHEN COALESCE(ss.total_orders, 0) = 0 THEN 0
        ELSE ROUND(
            ss.gross_sales / ss.total_orders,
            2
        )
    END AS average_order_value,

    COALESCE(rating_stats.average_product_rating, 0)
        AS average_product_rating,

    CASE
        WHEN COALESCE(ss.total_items_sold, 0) = 0 THEN 0
        ELSE ROUND(
            COALESCE(ret.returned_quantity, 0)
            / ss.total_items_sold * 100,
            2
        )
    END AS return_rate,

    COALESCE(bp.product_name, 'No Sales')
        AS best_selling_product,

    ss.last_sale_date,

    COALESCE(ps.current_stock_value, 0)
        AS current_stock_value

FROM sellers s

LEFT JOIN product_stats ps
    ON ps.seller_id = s.id

LEFT JOIN sales_stats ss
    ON ss.seller_id = s.id

LEFT JOIN refund_stats rs
    ON rs.seller_id = s.id

LEFT JOIN rating_stats
    ON rating_stats.seller_id = s.id

LEFT JOIN return_stats ret
    ON ret.seller_id = s.id

LEFT JOIN best_products bp
    ON bp.seller_id = s.id
    AND bp.rn = 1

ORDER BY s.id;











UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE id = 1
  AND stock_quantity >= 1;

UPDATE products
SET stock_quantity = 100
WHERE id = 1;


SELECT
    id,
    product_name,
    stock_quantity
FROM products
WHERE id = 1;


DELIMITER //

DROP PROCEDURE IF EXISTS stress_test_purchase//

CREATE PROCEDURE stress_test_purchase(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT stock_quantity
    INTO v_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found';

    END IF;

    IF v_stock < p_quantity THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';

    END IF;

    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE id = p_product_id;

    COMMIT;
END//

DELIMITER ;





SELECT
    id,
    product_name,
    stock_quantity
FROM products
WHERE id = 1;



SELECT stock_quantity
FROM products
WHERE id = 1;

SELECT
    id,
    product_name,
    stock_quantity
FROM products
WHERE stock_quantity < 0;

SELECT
    o.id,
    o.order_number,
    o.total_amount,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM orders o
LEFT JOIN payments p
    ON p.order_id = o.id
    AND p.status = 'paid'
GROUP BY
    o.id,
    o.order_number,
    o.total_amount
HAVING COALESCE(SUM(p.amount), 0) > o.total_amount;


SELECT
    oi.id AS order_item_id,
    oi.quantity AS purchased_quantity,
    COALESCE(SUM(r.quantity), 0) AS returned_quantity
FROM order_items oi
LEFT JOIN returns r
    ON r.order_item_id = oi.id
    AND r.status IN ('approved', 'completed')
GROUP BY
    oi.id,
    oi.quantity
HAVING COALESCE(SUM(r.quantity), 0) > oi.quantity;



SELECT
    p.id AS payment_id,
    p.amount AS payment_amount,
    COALESCE(SUM(rf.amount), 0) AS refunded_amount
FROM payments p
LEFT JOIN refunds rf
    ON rf.payment_id = p.id
    AND rf.status = 'completed'
GROUP BY
    p.id,
    p.amount
HAVING COALESCE(SUM(rf.amount), 0) > p.amount;



SELECT
    id,
    order_id,
    seller_id,
    quantity,
    unit_price,
    discount_amount,
    platform_commission,
    seller_amount
FROM order_items
WHERE ROUND(
          (quantity * unit_price)
          - discount_amount
          - platform_commission,
          2
      )
      <> ROUND(seller_amount, 2);



SELECT
    payment_reference,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_reference
HAVING COUNT(*) > 1;



SELECT
    tracking_number,
    COUNT(*) AS duplicate_count
FROM shipments
GROUP BY tracking_number
HAVING COUNT(*) > 1;


SELECT
    seller_id,
    period_start,
    period_end,
    COUNT(*) AS settlement_count
FROM seller_settlements
GROUP BY
    seller_id,
    period_start,
    period_end
HAVING COUNT(*) > 1;



SELECT
    id,
    code,
    used_count,
    usage_limit
FROM coupons
WHERE used_count > usage_limit;



SELECT
    'Negative Stock' AS check_name,
    COUNT(*) AS error_count
FROM products
WHERE stock_quantity < 0

UNION ALL

SELECT
    'Returns Exceed Purchased Quantity',
    COUNT(*)
FROM
(
    SELECT
        oi.id
    FROM order_items oi
    LEFT JOIN returns r
        ON r.order_item_id = oi.id
        AND r.status IN ('approved', 'completed')
    GROUP BY oi.id, oi.quantity
    HAVING COALESCE(SUM(r.quantity), 0) > oi.quantity
) x

UNION ALL

SELECT
    'Refunds Exceed Payment',
    COUNT(*)
FROM
(
    SELECT
        p.id
    FROM payments p
    LEFT JOIN refunds rf
        ON rf.payment_id = p.id
        AND rf.status = 'completed'
    GROUP BY p.id, p.amount
    HAVING COALESCE(SUM(rf.amount), 0) > p.amount
) y

UNION ALL

SELECT
    'Duplicate Payment References',
    COUNT(*)
FROM
(
    SELECT payment_reference
    FROM payments
    GROUP BY payment_reference
    HAVING COUNT(*) > 1
) z

UNION ALL

SELECT
    'Coupon Usage Limit Exceeded',
    COUNT(*)
FROM coupons
WHERE used_count > usage_limit;




WITH order_stats AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN status = 'delivered' THEN 1
                ELSE 0
            END
        ) AS completed_orders,

        SUM(
            CASE
                WHEN status = 'cancelled' THEN 1
                ELSE 0
            END
        ) AS cancelled_orders,

        SUM(
            CASE
                WHEN status <> 'cancelled'
                THEN total_amount
                ELSE 0
            END
        ) AS total_spent,

        SUM(
            CASE
                WHEN status <> 'cancelled'
                THEN discount_amount
                ELSE 0
            END
        ) AS total_discount_received,

        AVG(
            CASE
                WHEN status <> 'cancelled'
                THEN total_amount
            END
        ) AS average_order_value,

        MAX(ordered_at) AS last_order_date

    FROM orders
    GROUP BY customer_id
),

purchase_stats AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT oi.product_id) AS unique_products_purchased,
        COUNT(DISTINCT oi.seller_id) AS unique_sellers
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    WHERE o.status <> 'cancelled'
    GROUP BY o.customer_id
),

return_stats AS
(
    SELECT
        o.customer_id,
        SUM(r.quantity) AS total_returns
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    JOIN returns r
        ON r.order_item_id = oi.id
    WHERE r.status IN ('approved', 'completed')
    GROUP BY o.customer_id
),

refund_stats AS
(
    SELECT
        o.customer_id,
        SUM(rf.amount) AS total_refunds
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    JOIN returns r
        ON r.order_item_id = oi.id
    JOIN refunds rf
        ON rf.return_id = r.id
    WHERE rf.status = 'completed'
    GROUP BY o.customer_id
),

category_stats AS
(
    SELECT
        o.customer_id,
        c.category_name,
        SUM(oi.quantity) AS quantity_sold,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rn

    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    JOIN products p
        ON p.id = oi.product_id
    JOIN categories c
        ON c.id = p.category_id

    WHERE o.status <> 'cancelled'

    GROUP BY
        o.customer_id,
        c.id,
        c.category_name
),

seller_stats AS
(
    SELECT
        o.customer_id,
        s.store_name,
        SUM(oi.quantity) AS quantity_sold,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rn

    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.id
    JOIN sellers s
        ON s.id = oi.seller_id

    WHERE o.status <> 'cancelled'

    GROUP BY
        o.customer_id,
        s.id,
        s.store_name
)

SELECT
    c.full_name AS customer,

    COALESCE(os.total_orders, 0) AS total_orders,

    COALESCE(os.completed_orders, 0) AS completed_orders,

    COALESCE(os.cancelled_orders, 0) AS cancelled_orders,

    COALESCE(ROUND(os.total_spent, 2), 0) AS total_spent,

    COALESCE(
        ROUND(os.total_discount_received, 2),
        0
    ) AS total_discount_received,

    COALESCE(ps.unique_products_purchased, 0)
        AS unique_products_purchased,

    COALESCE(ps.unique_sellers, 0)
        AS unique_sellers,

    COALESCE(rs.total_returns, 0)
        AS total_returns,

    COALESCE(
        ROUND(rfs.total_refunds, 2),
        0
    ) AS total_refunds,

    COALESCE(
        ROUND(os.average_order_value, 2),
        0
    ) AS average_order_value,

    COALESCE(
        cs.category_name,
        'No Purchase'
    ) AS favorite_category,

    COALESCE(
        ss.store_name,
        'No Purchase'
    ) AS favorite_seller,

    os.last_order_date

FROM customers c

LEFT JOIN order_stats os
    ON os.customer_id = c.id

LEFT JOIN purchase_stats ps
    ON ps.customer_id = c.id

LEFT JOIN return_stats rs
    ON rs.customer_id = c.id

LEFT JOIN refund_stats rfs
    ON rfs.customer_id = c.id

LEFT JOIN category_stats cs
    ON cs.customer_id = c.id
    AND cs.rn = 1

LEFT JOIN seller_stats ss
    ON ss.customer_id = c.id
    AND ss.rn = 1

ORDER BY c.id;


-- ===========================================END=======================================


-- ================================================================================
  --                       DATABASE 4
-- ================================================================================



-- أمر إنشاء قاعدة البيانات مع الترميز الخاص بها 

CREATE DATABASE hospital_management
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hospital_management;


-- أمر إنشاء جدول ال ( departments ) مع الحماية الكاملة عليه 

CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT,
    department_name VARCHAR(100) NOT NULL CHECK (TRIM(department_name) <> ''),
    floor_number INT NOT NULL CHECK (floor_number > 0),
    phone VARCHAR(20) NOT NULL CHECK (TRIM(phone) <> ''),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'maintenance')),
    FOREIGN KEY  (parent_id) REFERENCES departments(id) 
    ON UPDATE CASCADE
    ON DELETE SET NULL
);


-- كود إضافة فهرس على عمودي اسم القسم ورقم الطابق

CREATE UNIQUE INDEX idx_departments_name_floor
ON departments (department_name, floor_number);



-- أمر إنشاء جدول ( doctors ) مع الحماية الكاملة عليه 

CREATE TABLE doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_id INT NOT NULL,
    full_name VARCHAR(150) NOT NULL CHECK (TRIM(full_name) <> ''),
    email VARCHAR(150) NOT NULL UNIQUE CHECK (TRIM(email) <> ''),
    phone VARCHAR(20) NOT NULL UNIQUE CHECK (TRIM(phone) <> ''),
    specialization VARCHAR(100) NOT NULL CHECK (TRIM(specialization) <> ''),
    license_number VARCHAR(100) NOT NULL UNIQUE CHECK (TRIM(license_number) <> ''),
    hire_date DATE NOT NULL,
    consultation_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00
        CHECK (consultation_fee >= 0.00),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'on_leave')),

    FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- أمر إنشاء الفهارس المناسبة على جدول الأطباء لتسهيل البحث 

CREATE INDEX idx_doctors_department
ON doctors (department_id);

CREATE INDEX idx_doctors_specialization
ON doctors (specialization);



-- أمر إنشاء جدول ال ( patients ) مع الحماية الكاملة عليه

CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL CHECK (TRIM(full_name) <> ''),
    national_id VARCHAR(50) NOT NULL UNIQUE CHECK (TRIM(national_id) <> ''),
    birth_date DATE NOT NULL,
    gender VARCHAR(20) NOT NULL
        CHECK (gender IN ('Male', 'Female')),
    phone VARCHAR(20) NOT NULL UNIQUE CHECK (TRIM(phone) <> ''),
    email VARCHAR(150) NOT NULL UNIQUE CHECK (TRIM(email) <> ''),
    blood_type VARCHAR(10) NOT NULL
        CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    city VARCHAR(100) NOT NULL CHECK (TRIM(city) <> ''),
    address VARCHAR(255) NOT NULL CHECK (TRIM(address) <> ''),
    emergency_contact_name VARCHAR(150) NOT NULL
        CHECK (TRIM(emergency_contact_name) <> ''),
    emergency_contact_phone VARCHAR(20) NOT NULL
        CHECK (TRIM(emergency_contact_phone) <> ''),
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'admitted'))
);


-- أمر إنشاء فهرس على الجدول لتسهيل البحث 

CREATE INDEX idx_patients_city
ON patients (city);



-- أمر إنشاء جدول ( rooms ) مع حماية كل الأعمدة 

CREATE TABLE rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_id INT NOT NULL,
    room_number VARCHAR(50) NOT NULL UNIQUE
        CHECK (TRIM(room_number) <> ''),
    room_type VARCHAR(50) NOT NULL
        CHECK (room_type IN ('normal', 'private', 'icu', 'emergency')),
    floor_number INT NOT NULL
        CHECK (floor_number > 0),
    daily_price DECIMAL(10,2) NOT NULL DEFAULT 0.00
        CHECK (daily_price >= 0.00),
    status VARCHAR(20) NOT NULL DEFAULT 'available'
        CHECK (status IN ('available', 'occupied', 'maintenance', 'inactive')),

    FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- أمر إنشاء فهارس على الجدول لتسهيل البحث 

CREATE INDEX idx_rooms_department
ON rooms (department_id);

CREATE INDEX idx_rooms_status
ON rooms (status);



-- أمر إنشاء جدول ال ( appointments ) مع الحماية الكاملة عليه

CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(255) NOT NULL CHECK (TRIM(reason) <> ''),
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- إضافة فهارس على الجدول لتسهيل عملية البحث 

CREATE INDEX idx_appointments_patient
ON appointments (patient_id);

CREATE INDEX idx_appointments_doctor
ON appointments (doctor_id);

CREATE INDEX idx_appointments_date
ON appointments (appointment_date);



-- أمر إنشاء جدول ال ( medical_visits ) مع الحماية الكاملة عليه

CREATE TABLE medical_visits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT NOT NULL DEFAULT 0,
    visit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptoms VARCHAR(255) NOT NULL CHECK (TRIM(symptoms) <> ''),
    diagnosis VARCHAR(255) NOT NULL CHECK (TRIM(diagnosis) <> ''),
    doctor_notes VARCHAR(500) NOT NULL DEFAULT 'لا توجد ملاحظات' CHECK (TRIM(doctor_notes) <> ''),
    follow_up_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- أمر إنشاء الفهارس لتسهيل البحث بالجدول 

CREATE INDEX idx_medical_visits_patient ON medical_visits (patient_id);
CREATE INDEX idx_medical_visits_doctor ON medical_visits (doctor_id);
CREATE INDEX idx_medical_visits_date ON medical_visits (visit_date);

-- أمر إنشاء مشغل ( trigger ) لحماية الفهرس الاجنبي

DELIMITER //

CREATE TRIGGER check_appointment_validity
BEFORE INSERT ON medical_visits
FOR EACH ROW
BEGIN
    IF NEW.appointment_id <> 0 AND NOT EXISTS (SELECT 1 FROM appointments WHERE id = NEW.appointment_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Appointment ID does not exist in the system!';
    END IF;
END;
//

DELIMITER ;

-- أمر إنشاء جدول ( medicines ) مع الحماية الخاصة بالاعمدة

CREATE TABLE medicines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_name VARCHAR(100) NOT NULL DEFAULT 'Unnamed Medicine' CHECK (TRIM(medicine_name) <> ''),
    manufacturer VARCHAR(100) NOT NULL DEFAULT 'Unknown' CHECK (TRIM(manufacturer) <> ''),
    unit_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (unit_price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    minimum_stock INT NOT NULL DEFAULT 0 CHECK (minimum_stock >= 0),
    expiry_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Available' CHECK (status IN ('Available', 'Out of Stock', 'Expired', 'Discontinued'))
);

-- أمر انشاء الفهارس المناسبة لنسهيل الاستعلام 

CREATE INDEX idx_medicines_name ON medicines (medicine_name);
CREATE INDEX idx_medicines_status ON medicines (status);
CREATE INDEX idx_medicines_expiry ON medicines (expiry_date);

-- أمر إنشاء جدول ( prescriptions ) مع حمايته 

CREATE TABLE prescriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT NOT NULL,
    prescribed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(500) NOT NULL DEFAULT 'لا توجد ملاحظات' CHECK (TRIM(notes) <> ''), 
    FOREIGN KEY (visit_id) REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- أمر إنشاء الفهارس على الجدول لتسهيل البحث فيه

CREATE INDEX idx_prescriptions_visit ON prescriptions (visit_id);

-- أمر إنشاء جدول ( prescription_items ) مع الحماية على الجداول

CREATE TABLE prescription_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL CHECK (TRIM(dosage) <> ''),
    frequency VARCHAR(100) NOT NULL CHECK (TRIM(frequency) <> ''),
    duration_days INT NOT NULL DEFAULT 1 CHECK (duration_days > 0),
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- أمر إنشاء الفهارس على الجدول 

CREATE INDEX idx_prescription_items_prescription ON prescription_items (prescription_id);
CREATE INDEX idx_prescription_items_medicine ON prescription_items (medicine_id);

-- أمر إنشاء جدول ( lab_tests ) مع كامل الحماية عليه

CREATE TABLE lab_tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100) NOT NULL DEFAULT 'Unnamed Test' CHECK (TRIM(test_name) <> ''),
    category VARCHAR(100) NOT NULL DEFAULT 'General' CHECK (TRIM(category) <> ''),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (price >= 0),
    normal_range VARCHAR(100) NOT NULL DEFAULT 'Not Specified' CHECK (TRIM(normal_range) <> ''),
    status VARCHAR(50) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Discontinued'))
);

-- أمر إنشاء الفهارس على الجدول لتسهيل البحث

CREATE INDEX idx_lab_tests_name ON lab_tests (test_name);
CREATE INDEX idx_lab_tests_category ON lab_tests (category);
CREATE INDEX idx_lab_tests_status ON lab_tests (status);

-- أمر إنشاء جدول ( patient_lab_tests ) مع الحماية الكاملة على اعمدته 

CREATE TABLE patient_lab_tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT NOT NULL,
    lab_test_id INT NOT NULL,
    ordered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    result TEXT NOT NULL DEFAULT 'Pending Result' CHECK (TRIM(result) <> ''),
    result_status VARCHAR(50) NOT NULL DEFAULT 'Normal' CHECK (TRIM(result_status) <> ''),
    status VARCHAR(50) NOT NULL DEFAULT 'ordered' CHECK (status IN ('ordered', 'processing', 'completed', 'cancelled')),
    FOREIGN KEY (visit_id) REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (lab_test_id) REFERENCES lab_tests(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (completed_at >= ordered_at)
);

-- أمر انشاء الفهارس المناسبة على الجدول 

CREATE INDEX idx_patient_lab_tests_visit ON patient_lab_tests (visit_id);
CREATE INDEX idx_patient_lab_tests_test ON patient_lab_tests (lab_test_id);
CREATE INDEX idx_patient_lab_tests_status ON patient_lab_tests (status);

-- أمر إنشاء جدول (admissions) مع حمايته

CREATE TABLE admissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    doctor_id INT NOT NULL,
    admitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discharged_at DATETIME NULL,
    admission_reason VARCHAR(255) NOT NULL DEFAULT 'General Admission' CHECK (TRIM(admission_reason) <> ''),
    status VARCHAR(50) NOT NULL DEFAULT 'admitted' CHECK (status IN ('admitted', 'discharged', 'cancelled')),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (discharged_at >= admitted_at)
);

-- أمر إنشاء الفهارس المناسبة لتسهيل البحث

CREATE INDEX idx_admissions_patient ON admissions (patient_id);
CREATE INDEX idx_admissions_room ON admissions (room_id);
CREATE INDEX idx_admissions_doctor ON admissions (doctor_id);
CREATE INDEX idx_admissions_status ON admissions (status);
CREATE INDEX idx_admissions_admitted_at ON admissions (admitted_at);

-- أمر إنشاء جدول ( insurance_companies ) مع حمايته  

CREATE TABLE insurance_companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL DEFAULT 'Unnamed Company' CHECK (TRIM(company_name) <> ''),
    phone VARCHAR(50) NOT NULL UNIQUE DEFAULT 'Not Specified' CHECK (TRIM(phone) <> ''),
    email VARCHAR(100) NOT NULL UNIQUE DEFAULT 'no-email@hospital.com' CHECK (TRIM(email) <> ''),
    coverage_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00 CHECK (coverage_percentage >= 0 AND coverage_percentage <= 100),
    status VARCHAR(50) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive'))
);

-- أمر إنشاء الفهارس المناسبة 

CREATE INDEX idx_insurance_companies_name ON insurance_companies (company_name);
CREATE INDEX idx_insurance_companies_status ON insurance_companies (status);

-- أمر إنشاء جدول ( patient_insurance ) مع حمايته كاملاً 
 
CREATE TABLE patient_insurance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    insurance_company_id INT NOT NULL,
    policy_number VARCHAR(100) NOT NULL UNIQUE CHECK (TRIM(policy_number) <> ''),
    start_date DATE NOT NULL,
    expiry_date DATE NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Expired', 'Cancelled')),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (insurance_company_id) REFERENCES insurance_companies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (expiry_date >= start_date)
);

-- أمر إنشاء الفهارس المناسبة 

CREATE INDEX idx_patient_insurance_patient ON patient_insurance (patient_id);
CREATE INDEX idx_patient_insurance_company ON patient_insurance (insurance_company_id);
CREATE INDEX idx_patient_insurance_status ON patient_insurance (status);

-- أمر إنشاء جدول ال ( invoices ) مع حماية كل اعمدته بالكامل 

CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    visit_id INT NOT NULL,
    admission_id INT,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    insurance_discount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (insurance_discount >= 0),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partially_paid', 'paid', 'cancelled')),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (visit_id) REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (admission_id) REFERENCES admissions(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- أمر إنشاء الفهارس المناسبة على الجدول لتسهيل عملية البحث 

CREATE INDEX idx_invoices_patient ON invoices (patient_id);
CREATE INDEX idx_invoices_visit ON invoices (visit_id);
CREATE INDEX idx_invoices_admission ON invoices (admission_id);
CREATE INDEX idx_invoices_status ON invoices (payment_status);
CREATE INDEX idx_invoices_issued_at ON invoices (issued_at);

-- أمر إنشاء جدول ( payments ) مع حمايه كل الاعمدة 

CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
    payment_method VARCHAR(50) NOT NULL DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'pix', 'bank_transfer', 'insurance')),
    transaction_reference VARCHAR(100) NOT NULL DEFAULT 'N/A' CHECK (TRIM(transaction_reference) <> ''),
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'pending', 'failed', 'refunded')),
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- أمر إنشاء كل الفهارس المناسبة لتسهيل البحث

CREATE INDEX idx_payments_invoice ON payments (invoice_id);
CREATE INDEX idx_payments_status ON payments (status);
CREATE INDEX idx_payments_method ON payments (payment_method);

-- من هنا تبدا أكواد إدخال البيانات 

INSERT INTO departments (department_name, floor_number, phone, status) VALUES
('Emergency Department', 1, '+1-555-0101', 'active'),
('Cardiology', 2, '+1-555-0102', 'active'),
('Pediatrics', 3, '+1-555-0103', 'active'),
('Orthopedics', 2, '+1-555-0104', 'active'),
('Neurology', 4, '+1-555-0105', 'active'),
('Radiology', 1, '+1-555-0106', 'active'),
('Internal Medicine', 3, '+1-555-0107', 'active'),
('Ophthalmology', 4, '+1-555-0108', 'active');



INSERT INTO doctors (department_id, full_name, email, phone, specialization, license_number, hire_date, consultation_fee, status) VALUES
(1, 'Dr. Ahmed Al-Masri', 'ahmed.masri@hospital.com', '+1-555-1101', 'Emergency Medicine', 'LIC-1001', '2022-01-15', 150.0, 'active'),
(2, 'Dr. Sarah Johnson', 'sarah.johnson@hospital.com', '+1-555-1102', 'Cardiologist', 'LIC-1002', '2021-05-20', 250.0, 'active'),
(3, 'Dr. Mohammed Al-Khatib', 'mohammed.khatib@hospital.com', '+1-555-1103', 'Pediatrician', 'LIC-1003', '2023-02-10', 120.0, 'active'),
(4, 'Dr. Emily Davis', 'emily.davis@hospital.com', '+1-555-1104', 'Orthopedic Surgeon', 'LIC-1004', '2020-11-05', 300.0, 'active'),
(5, 'Dr. Omar Farooq', 'omar.farooq@hospital.com', '+1-555-1105', 'Neurologist', 'LIC-1005', '2019-08-12', 280.0, 'active'),
(6, 'Dr. Laura Wilson', 'laura.wilson@hospital.com', '+1-555-1106', 'Radiologist', 'LIC-1006', '2022-04-18', 200.0, 'active'),
(7, 'Dr. Khalid Mansour', 'khalid.mansour@hospital.com', '+1-555-1107', 'Internal Medicine', 'LIC-1007', '2021-09-30', 140.0, 'active'),
(8, 'Dr. Jessica Taylor', 'jessica.taylor@hospital.com', '+1-555-1108', 'Ophthalmologist', 'LIC-1008', '2023-01-25', 180.0, 'active'),
(1, 'Dr. Rami Nazzal', 'rami.nazzal@hospital.com', '+1-555-1109', 'Emergency Medicine', 'LIC-1009', '2023-06-11', 150.0, 'active'),
(2, 'Dr. Elena Rostova', 'elena.rostova@hospital.com', '+1-555-1110', 'Cardiologist', 'LIC-1010', '2020-03-14', 250.0, 'active'),
(3, 'Dr. Youssef Nader', 'youssef.nader@hospital.com', '+1-555-1111', 'Pediatrician', 'LIC-1011', '2022-10-01', 120.0, 'active'),
(4, 'Dr. Anna Smith', 'anna.smith@hospital.com', '+1-555-1112', 'Orthopedic Surgeon', 'LIC-1012', '2021-12-19', 300.0, 'active'),
(5, 'Dr. Ziad Tariq', 'ziad.tariq@hospital.com', '+1-555-1113', 'Neurologist', 'LIC-1013', '2022-07-07', 280.0, 'active'),
(6, 'Dr. Maria Garcia', 'maria.garcia@hospital.com', '+1-555-1114', 'Radiologist', 'LIC-1014', '2018-05-16', 200.0, 'active'),
(7, 'Dr. Hassan Al-Amine', 'hassan.amine@hospital.com', '+1-555-1115', 'Internal Medicine', 'LIC-1015', '2023-03-22', 140.0, 'active'),
(8, 'Dr. Chloe Martin', 'chloe.martin@hospital.com', '+1-555-1116', 'Ophthalmologist', 'LIC-1016', '2020-09-09', 180.0, 'active'),
(1, 'Dr. Fadi Haddad', 'fadi.haddad@hospital.com', '+1-555-1117', 'Emergency Medicine', 'LIC-1017', '2024-01-10', 160.0, 'active'),
(2, 'Dr. Robert Chen', 'robert.chen@hospital.com', '+1-555-1118', 'Cardiologist', 'LIC-1018', '2019-11-25', 260.0, 'active'),
(3, 'Dr. Mona Zaki', 'mona.zaki@hospital.com', '+1-555-1119', 'Pediatrician', 'LIC-1019', '2023-08-14', 125.0, 'active'),
(4, 'Dr. David Miller', 'david.miller@hospital.com', '+1-555-1120', 'Orthopedic Surgeon', 'LIC-1020', '2021-02-28', 290.0, 'active'),
(5, 'Dr. Samer Kassir', 'samer.kassir@hospital.com', '+1-555-1121', 'Neurologist', 'LIC-1021', '2022-05-12', 270.0, 'active'),
(6, 'Dr. Raniah Saed', 'raniah.saed@hospital.com', '+1-555-1122', 'Radiologist', 'LIC-1022', '2023-04-05', 190.0, 'active'),
(7, 'Dr. Tarek Basha', 'tarek.basha@hospital.com', '+1-555-1123', 'Internal Medicine', 'LIC-1023', '2020-10-15', 135.0, 'active'),
(8, 'Dr. Nadine Labaki', 'nadine.labaki@hospital.com', '+1-555-1124', 'Ophthalmologist', 'LIC-1024', '2021-07-19', 175.0, 'active'),
(2, 'Dr. Karim Fawzi', 'karim.fawzi@hospital.com', '+1-555-1125', 'Cardiologist', 'LIC-1025', '2024-02-01', 250.0, 'active');

INSERT INTO patients (full_name, national_id, birth_date, gender, phone, email, blood_type, city, address, emergency_contact_name, emergency_contact_phone, registered_at, status) VALUES
('Ibrahim Al-Sayed', 'ID100001', '1985-05-12', 'Male', '+1-555-2001', 'ibrahim.sayed@gmail.com', 'A+', 'Beirut', 'Street 10, Building 3', 'Fatima Al-Sayed', '+1-555-2901', '2026-01-10 10:00:00', 'active'),
('Zainab Ali', 'ID100002', '1990-08-22', 'Female', '+1-555-2002', 'zainab.ali@gmail.com', 'O+', 'Beirut', 'Street 5, Building 12', 'Ali Ali', '+1-555-2902', '2026-01-11 11:30:00', 'active'),
('Mahmoud Hassan', 'ID100003', '1975-03-15', 'Male', '+1-555-2003', 'mahmoud.hassan@gmail.com', 'B+', 'Tripoli', 'Main Road, Apt 4', 'Amina Hassan', '+1-555-2903', '2026-01-12 09:15:00', 'active'),
('Layla Mourad', 'ID100004', '1992-11-30', 'Female', '+1-555-2004', 'layla.mourad@gmail.com', 'AB+', 'Sidon', 'Sea Side Ave', 'Samir Mourad', '+1-555-2904', '2026-01-15 14:20:00', 'active'),
('Khaled Othman', 'ID100005', '1982-07-19', 'Male', '+1-555-2005', 'khaled.othman@gmail.com', 'O-', 'Byblos', 'Old Market St', 'Rula Othman', '+1-555-2905', '2026-01-16 08:45:00', 'active'),
('Nourhan Salem', 'ID100006', '1998-02-05', 'Female', '+1-555-2006', 'nourhan.salem@gmail.com', 'A-', 'Zahle', 'University St', 'Tamer Salem', '+1-555-2906', '2026-01-18 16:00:00', 'active'),
('Sami Barakat', 'ID100007', '1968-12-01', 'Male', '+1-555-2007', 'sami.barakat@gmail.com', 'B-', 'Beirut', 'Hamra St', 'Nada Barakat', '+1-555-2907', '2026-01-20 10:10:00', 'active'),
('Raniah Jaber', 'ID100008', '1995-06-25', 'Female', '+1-555-2008', 'rania.jaber@gmail.com', 'AB-', 'Tripoli', '醫院 St', 'Hadi Jaber', '+1-555-2908', '2026-01-22 13:50:00', 'active'),
('Bilal Nasser', 'ID100009', '1988-09-10', 'Male', '+1-555-2009', 'bilal.nasser@gmail.com', 'O+', 'Tyre', 'Corniche Rd', 'Sawsan Nasser', '+1-555-2909', '2026-01-25 09:30:00', 'active'),
('Dina Farhat', 'ID100010', '2000-04-14', 'Female', '+1-555-2010', 'dina.farhat@gmail.com', 'A+', 'Beirut', 'Achrafieh St', 'Ziad Farhat', '+1-555-2910', '2026-01-26 11:00:00', 'active'),
('Tariq Zidan', 'ID100011', '1979-10-03', 'Male', '+1-555-2011', 'tariq.zidan@gmail.com', 'B+', 'Sidon', 'Park Ave', 'Mona Zidan', '+1-555-2911', '2026-01-28 15:15:00', 'active'),
('Hala Kanso', 'ID100012', '1993-01-18', 'Female', '+1-555-2012', 'hala.kanso@gmail.com', 'O-', 'Jounieh', 'Bay Rd', 'Adel Kanso', '+1-555-2912', '2026-02-01 08:30:00', 'active'),
('Rami Daher', 'ID100013', '1986-07-28', 'Male', '+1-555-2013', 'rami.daher@gmail.com', 'A-', 'Beirut', 'Verdun St', 'Noha Daher', '+1-555-2913', '2026-02-03 12:00:00', 'active'),
('Yasmin Radi', 'ID100014', '1991-05-09', 'Female', '+1-555-2014', 'yasmin.radi@gmail.com', 'AB+', 'Tripoli', 'Al-Mina St', 'Karim Radi', '+1-555-2914', '2026-02-05 10:45:00', 'active'),
('Adel Shami', 'ID100015', '1972-12-19', 'Male', '+1-555-2015', 'adel.shami@gmail.com', 'B-', 'Zahle', 'Main St', 'Samira Shami', '+1-555-2915', '2026-02-08 09:00:00', 'active'),
('Maha Traboulsi', 'ID100016', '1997-03-21', 'Female', '+1-555-2016', 'maha.traboulsi@gmail.com', 'O+', 'Beirut', 'Ras Beirut', 'Fadi Traboulsi', '+1-555-2916', '2026-02-10 14:10:00', 'active'),
('Wael Halabi', 'ID100017', '1980-08-11', 'Male', '+1-555-2017', 'wael.halabi@gmail.com', 'A+', 'Sidon', 'Old City', 'Rima Halabi', '+1-555-2917', '2026-02-12 11:20:00', 'active'),
('Sawsan Akari', 'ID100018', '1994-09-17', 'Female', '+1-555-2018', 'sawsan.akari@gmail.com', 'AB-', 'Byblos', 'Harbor Rd', 'Nabil Akari', '+1-555-2918', '2026-02-15 16:30:00', 'active'),
('Ziad Maalouf', 'ID100019', '1977-06-04', 'Male', '+1-555-2019', 'ziad.maalouf@gmail.com', 'B+', 'Beirut', 'Badaro St', 'Eliane Maalouf', '+1-555-2919', '2026-02-18 10:00:00', 'active'),
('Nadine Salam', 'ID100020', '1989-10-29', 'Female', '+1-555-2020', 'nadine.salam@gmail.com', 'O-', 'Tripoli', 'Azmi St', 'George Salam', '+1-555-2920', '2026-02-20 13:15:00', 'active'),
('Fadi Ghanem', 'ID100021', '1983-02-14', 'Male', '+1-555-2021', 'fadi.ghanem@gmail.com', 'A-', 'Beirut', 'Mar Mikhael', 'Maya Ghanem', '+1-555-2921', '2026-02-22 09:40:00', 'active'),
('Maya Karam', 'ID100022', '1996-12-07', 'Female', '+1-555-2022', 'maya.karam@gmail.com', 'B-', 'Zahle', 'Industrial Rd', 'Joseph Karam', '+1-555-2922', '2026-02-25 15:00:00', 'active'),
('Nabil Kassir', 'ID100023', '1974-04-20', 'Male', '+1-555-2023', 'nabil.kassir@gmail.com', 'AB+', 'Sidon', 'Riad El Solh', 'Salma Kassir', '+1-555-2923', '2026-02-28 08:50:00', 'active'),
('Rula Saad', 'ID100024', '1990-07-13', 'Female', '+1-555-2024', 'rula.saad@gmail.com', 'O+', 'Tyre', 'Al-Bass St', 'Elias Saad', '+1-555-2924', '2026-03-01 10:30:00', 'active'),
('Elias Matar', 'ID100025', '1981-11-02', 'Male', '+1-555-2025', 'elias.matar@gmail.com', 'A+', 'Beirut', 'Furn El Chebbak', 'Carla Matar', '+1-555-2925', '2026-03-03 12:20:00', 'active'),
('Carla Khoury', 'ID100026', '1995-01-26', 'Female', '+1-555-2026', 'carla.khoury@gmail.com', 'B+', 'Jounieh', 'Autostrad', 'Georges Khoury', '+1-555-2926', '2026-03-05 14:00:00', 'active'),
('Georges Chaoul', 'ID100027', '1976-06-18', 'Male', '+1-555-2027', 'georges.chaoul@gmail.com', 'O-', 'Byblos', 'University Rd', 'Therese Chaoul', '+1-555-2927', '2026-03-08 09:10:00', 'active'),
('Therese Azar', 'ID100028', '1992-08-05', 'Female', '+1-555-2028', 'therese.azar@gmail.com', 'AB-', 'Beirut', 'Sodeco', 'Pierre Azar', '+1-555-2928', '2026-03-10 11:45:00', 'active'),
('Pierre Sfeir', 'ID100029', '1984-03-09', 'Male', '+1-555-2029', 'pierre.sfeir@gmail.com', 'A-', 'Tripoli', 'Tall Square', 'Noha Sfeir', '+1-555-2929', '2026-03-12 15:30:00', 'active'),
('Noha Haddad', 'ID100030', '1999-10-11', 'Female', '+1-555-2030', 'noha.haddad@gmail.com', 'B-', 'Sidon', 'ablus St', 'Samir Haddad', '+1-555-2930', '2026-03-15 08:15:00', 'active'),
('Samir Naccour', 'ID100031', '1970-09-24', 'Male', '+1-555-2031', 'samir.naccour@gmail.com', 'O+', 'Zahle', 'Railway St', 'Rita Naccour', '+1-555-2931', '2026-03-18 10:00:00', 'active'),
('Rita Boushnak', 'ID100032', '1987-12-04', 'Female', '+1-555-2032', 'rita.boushnak@gmail.com', 'AB+', 'Beirut', 'Corniche El Mazraa', 'Ziad Boushnak', '+1-555-2932', '2026-03-20 13:20:00', 'active'),
('Hassan Mroueh', 'ID100033', '1978-05-27', 'Male', '+1-555-2033', 'hassan.mroueh@gmail.com', 'A+', 'Tyre', 'Main Market', 'Fatima Mroueh', '+1-555-2933', '2026-03-22 09:50:00', 'active'),
('Fatima Choucair', 'ID100034', '1993-02-15', 'Female', '+1-555-2034', 'fatima.choucair@gmail.com', 'B+', 'Beirut', 'Manara', 'Ali Choucair', '+1-555-2934', '2026-03-25 16:10:00', 'active'),
('Ali Fakih', 'ID100035', '1985-08-08', 'Male', '+1-555-2035', 'ali.fakih@gmail.com', 'O-', 'Nabatieh', 'Hospital St', 'Zainab Fakih', '+1-555-2935', '2026-03-28 11:00:00', 'active'),
('Zainab Bazzi', 'ID100036', '1996-06-19', 'Female', '+1-555-2036', 'zainab.bazzi@gmail.com', 'A-', 'Bint Jbeil', 'Main St', 'Hassan Bazzi', '+1-555-2936', '2026-03-30 14:30:00', 'active'),
('Hussein Hammoud', 'ID100037', '1982-01-30', 'Male', '+1-555-2037', 'hussein.hammoud@gmail.com', 'AB-', 'Beirut', 'Dahiyeh', 'Mariam Hammoud', '+1-555-2937', '2026-04-02 09:20:00', 'active'),
('Mariam Zein', 'ID100038', '1991-04-12', 'Female', '+1-555-2038', 'mariam.zein@gmail.com', 'B-', 'Sidon', 'Old Harbour', 'Ahmad Zein', '+1-555-2938', '2026-04-05 10:40:00', 'active'),
('Ahmad Dakik', 'ID100039', '1979-07-21', 'Male', '+1-555-2039', 'ahmad.dakik@gmail.com', 'O+', 'Tyre', 'Commercial St', 'Suha Dakik', '+1-555-2939', '2026-04-08 13:00:00', 'active'),
('Suha Harb', 'ID100040', '1994-11-16', 'Female', '+1-555-2040', 'suha.harb@gmail.com', 'A+', 'Beirut', 'Tariq El Jdideh', 'Bilal Harb', '+1-555-2940', '2026-04-10 15:20:00', 'active'),
('Kassem Al-Amin', 'ID100041', '1973-10-08', 'Male', '+1-555-2041', 'kassem.amin@gmail.com', 'B+', 'Baalbek', 'Roman St', 'Wafaa Al-Amin', '+1-555-2941', '2026-04-12 08:30:00', 'active'),
('Wafaa Ismail', 'ID100042', '1988-03-25', 'Female', '+1-555-2042', 'wafaa.ismail@gmail.com', 'AB+', 'Hermel', 'Main Rd', 'Hassan Ismail', '+1-555-2942', '2026-04-15 11:10:00', 'active'),
('Imad Shaito', 'ID100043', '1980-12-05', 'Male', '+1-555-2043', 'imad.shaito@gmail.com', 'O-', 'Beirut', 'Clemenceau', 'Randa Shaito', '+1-555-2943', '2026-04-18 12:00:00', 'active'),
('Randa Mneimneh', 'ID100044', '1992-05-14', 'Female', '+1-555-2044', 'randa.mneimneh@gmail.com', 'A-', 'Beirut', 'Corniche', 'Ziad Mneimneh', '+1-555-2944', '2026-04-20 09:15:00', 'active'),
('Nizar Sinno', 'ID100045', '1975-09-01', 'Male', '+1-555-2045', 'nizar.sinno@gmail.com', 'B-', 'Beirut', 'Kantari', 'Lina Sinno', '+1-555-2945', '2026-04-22 14:45:00', 'active'),
('Lina Itani', 'ID100046', '1997-02-18', 'Female', '+1-555-2046', 'lina.itani@gmail.com', 'AB-', 'Beirut', 'Wata', 'Omar Itani', '+1-555-2946', '2026-04-25 10:20:00', 'active'),
('Kamal Beydoun', 'ID100047', '1984-06-22', 'Male', '+1-555-2047', 'kamal.beydoun@gmail.com', 'O+', 'Tyre', 'Al-Housh', 'Nadia Beydoun', '+1-555-2947', '2026-04-28 16:00:00', 'active'),
('Nadia Chehab', 'ID100048', '1990-10-31', 'Female', '+1-555-2048', 'nadia.chehab@gmail.com', 'A+', 'Sidon', 'Dakerman', 'Samih Chehab', '+1-555-2948', '2026-05-01 08:50:00', 'active'),
('Samih Assaad', 'ID100049', '1971-01-15', 'Male', '+1-555-2049', 'samih.assaad@gmail.com', 'B+', 'Zahle', 'Berdawni', 'Salma Assaad', '+1-555-2949', '2026-05-03 11:30:00', 'active'),
('Salma Daouk', 'ID100050', '1995-07-09', 'Female', '+1-555-2050', 'salma.daouk@gmail.com', 'O-', 'Beirut', 'Sanayeh', 'Amine Daouk', '+1-555-2950', '2026-05-05 13:40:00', 'active'),
('Amine Sayegh', 'ID100051', '1986-04-03', 'Male', '+1-555-2051', 'amine.sayegh@gmail.com', 'A-', 'Beirut', 'Achrafieh', 'Nour Sayegh', '+1-555-2951', '2026-05-08 09:00:00', 'active'),
('Nour Bizri', 'ID100052', '1993-09-21', 'Female', '+1-555-2052', 'nour.bizri@gmail.com', 'B-', 'Sidon', 'Main St', 'Ziad Bizri', '+1-555-2952', '2026-05-10 10:15:00', 'active'),
('Ziad Kabbani', 'ID100053', '1978-12-11', 'Male', '+1-555-2053', 'ziad.kabbani@gmail.com', 'AB+', 'Beirut', 'Hamra', 'Mona Kabbani', '+1-555-2953', '2026-05-12 14:20:00', 'active'),
('Mona Solh', 'ID100054', '1991-02-27', 'Female', '+1-555-2054', 'mona.solh@gmail.com', 'O+', 'Tripoli', 'Tell', 'Tarek Solh', '+1-555-2954', '2026-05-15 11:00:00', 'active'),
('Tarek Mikati', 'ID100055', '1983-08-19', 'Male', '+1-555-2055', 'tarek.mikati@gmail.com', 'A+', 'Tripoli', 'Mina', 'Rania Mikati', '+1-555-2955', '2026-05-18 15:30:00', 'active'),
('Rania Karami', 'ID100056', '1996-05-04', 'Female', '+1-555-2056', 'rania.karami@gmail.com', 'B+', 'Tripoli', 'Azmi', 'Omar Karami', '+1-555-2956', '2026-05-20 08:40:00', 'active'),
('Omar Salam', 'ID100057', '1974-11-23', 'Male', '+1-555-2057', 'omar.salam@gmail.com', 'O-', 'Beirut', 'Verdun', 'Hoda Salam', '+1-555-2957', '2026-05-22 12:10:00', 'active'),
('Hoda Jisr', 'ID100058', '1989-06-16', 'Female', '+1-555-2058', 'hoda.jisr@gmail.com', 'AB-', 'Sidon', 'Sea Castle', 'Khaled Jisr', '+1-555-2958', '2026-05-25 09:50:00', 'active'),
('Khaled Houri', 'ID100059', '1981-01-29', 'Male', '+1-555-2059', 'khaled.houri@gmail.com', 'A-', 'Beirut', 'Mazraa', 'Layla Houri', '+1-555-2959', '2026-05-28 14:00:00', 'active'),
('Layla Rabbat', 'ID100060', '1994-07-07', 'Female', '+1-555-2060', 'layla.rabbat@gmail.com', 'B-', 'Beirut', 'Gemmayzeh', 'Sami Rabbat', '+1-555-2960', '2026-05-30 16:20:00', 'active');

INSERT INTO rooms (department_id, room_number, room_type, floor_number, daily_price, status) VALUES
(1, '1', 'normal', 1, 100.0, 'available'),
(2, '2', 'private', 1, 250.0, 'occupied'),
(3, '3', 'icu', 2, 600.0, 'available'),
(4, '4', 'emergency', 2, 450.0, 'occupied'),
(5, '5', 'normal', 3, 110.0, 'maintenance'),
(6, '6', 'private', 3, 260.0, 'available'),
(7, '7', 'icu', 4, 620.0, 'occupied'),
(8, '8', 'emergency', 4, 470.0, 'inactive'),
(1, '9', 'normal', 5, 120.0, 'available'),
(2, '10', 'private', 5, 270.0, 'occupied'),
(3, '11', 'icu', 6, 650.0, 'available'),
(4, '12', 'emergency', 6, 480.0, 'maintenance'),
(5, '13', 'normal', 7, 130.0, 'available'),
(6, '14', 'private', 7, 280.0, 'inactive'),
(7, '15', 'icu', 8, 700.0, 'occupied'),
(8, '16', 'emergency', 8, 500.0, 'available'),
(1, '17', 'normal', 9, 105.0, 'maintenance'),
(2, '18', 'private', 9, 255.0, 'available'),
(3, '19', 'icu', 10, 630.0, 'occupied'),
(4, '20', 'emergency', 10, 460.0, 'available'),
(5, '21', 'normal', 1, 115.0, 'inactive'),
(6, '22', 'private', 2, 265.0, 'occupied'),
(7, '23', 'icu', 3, 640.0, 'available'),
(8, '24', 'emergency', 4, 490.0, 'maintenance'),
(1, '25', 'normal', 5, 125.0, 'available'),
(2, '26', 'private', 6, 275.0, 'occupied'),
(3, '27', 'icu', 7, 680.0, 'available'),
(4, '28', 'emergency', 8, 510.0, 'inactive'),
(5, '29', 'normal', 9, 135.0, 'occupied'),
(6, '30', 'private', 10, 290.0, 'available');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at) VALUES
(3, 2, '2026-10-01', '09:00:00', 'Routine checkup', 'completed', '2026-09-25 08:30:00'),
(5, 4, '2026-10-01', '10:00:00', 'Headache', 'completed', '2026-09-25 09:15:00'),
(12, 1, '2026-10-01', '11:30:00', 'Fever and cough', 'completed', '2026-09-25 10:00:00'),
(3, 7, '2026-10-02', '08:30:00', 'Follow-up visit', 'no_show', '2026-09-25 11:20:00'),
(18, 3, '2026-10-02', '09:45:00', 'Back pain', 'completed', '2026-09-25 12:00:00'),
(22, 5, '2026-10-02', '11:00:00', 'Stomach ache', 'completed', '2026-09-25 13:10:00'),
(5, 2, '2026-10-03', '10:15:00', 'Skin rash', 'cancelled', '2026-09-26 08:00:00'),
(30, 8, '2026-10-03', '12:00:00', 'Eye irritation', 'completed', '2026-09-26 09:30:00'),
(35, 6, '2026-10-04', '09:00:00', 'Dental cleaning', 'completed', '2026-09-26 10:45:00'),
(12, 4, '2026-10-04', '10:30:00', 'Blood pressure check', 'no_show', '2026-09-26 11:15:00'),
(40, 10, '2026-10-05', '08:00:00', 'Joint pain', 'completed', '2026-09-27 08:20:00'),
(3, 1, '2026-10-05', '09:30:00', 'General consultation', 'completed', '2026-09-27 09:00:00'),
(45, 9, '2026-10-05', '11:00:00', 'Chest discomfort', 'completed', '2026-09-27 10:10:00'),
(18, 2, '2026-10-06', '09:15:00', 'Diabetes follow-up', 'completed', '2026-09-27 11:00:00'),
(50, 11, '2026-10-06', '10:45:00', 'Pediatric checkup', 'completed', '2026-09-27 12:30:00'),
(22, 6, '2026-10-07', '08:30:00', 'Earache', 'completed', '2026-09-28 08:10:00'),
(55, 12, '2026-10-07', '10:00:00', 'Allergy symptoms', 'completed', '2026-09-28 09:05:00'),
(30, 3, '2026-10-08', '11:15:00', 'Throat infection', 'completed', '2026-09-28 10:00:00'),
(60, 14, '2026-10-08', '12:30:00', 'Physical therapy session', 'completed', '2026-09-28 11:25:00'),
(5, 7, '2026-10-09', '09:00:00', 'Cardiac check', 'completed', '2026-09-28 12:00:00'),
(40, 15, '2026-10-09', '10:30:00', 'Orthopedic consultation', 'completed', '2026-09-28 13:00:00'),
(12, 5, '2026-10-10', '08:15:00', 'Flu symptoms', 'no_show', '2026-09-29 08:00:00'),
(35, 13, '2026-10-10', '09:45:00', 'Annual physical', 'completed', '2026-09-29 08:45:00'),
(50, 8, '2026-10-11', '11:00:00', 'Dermatology follow-up', 'completed', '2026-09-29 09:30:00'),
(18, 1, '2026-10-11', '12:15:00', 'Post-operative check', 'cancelled', '2026-09-29 10:15:00'),
(8, 16, '2026-10-12', '09:00:00', 'Routine checkup', 'completed', '2026-09-29 11:00:00'),
(15, 4, '2026-10-12', '10:30:00', 'Back pain', 'completed', '2026-09-29 11:30:00'),
(25, 9, '2026-10-13', '08:15:00', 'Headache', 'completed', '2026-09-29 12:00:00'),
(33, 2, '2026-10-13', '11:00:00', 'Fever', 'completed', '2026-09-29 12:15:00'),
(42, 11, '2026-10-14', '09:30:00', 'Stomach ache', 'completed', '2026-09-29 13:00:00'),
(51, 18, '2026-10-14', '10:45:00', 'Skin allergy', 'completed', '2026-09-29 13:30:00'),
(7, 20, '2026-10-15', '08:30:00', 'Dental pain', 'completed', '2026-09-30 08:00:00'),
(19, 22, '2026-10-15', '12:00:00', 'Eye check', 'completed', '2026-09-30 08:30:00'),
(28, 5, '2026-10-16', '09:00:00', 'Joint swelling', 'completed', '2026-09-30 09:00:00'),
(38, 12, '2026-10-16', '10:15:00', 'Throat pain', 'completed', '2026-09-30 09:30:00'),
(48, 1, '2026-10-17', '11:15:00', 'Chest pain', 'completed', '2026-09-30 10:00:00'),
(58, 14, '2026-10-17', '12:30:00', 'Physical therapy', 'completed', '2026-09-30 10:30:00'),
(2, 7, '2026-10-18', '08:45:00', 'Follow up', 'completed', '2026-09-30 11:00:00'),
(14, 17, '2026-10-18', '10:00:00', 'Dizziness', 'completed', '2026-09-30 11:30:00'),
(26, 23, '2026-10-19', '09:15:00', 'Cough and cold', 'completed', '2026-10-01 08:00:00'),
(36, 3, '2026-10-19', '11:30:00', 'Migraine', 'completed', '2026-10-01 08:30:00'),
(46, 25, '2026-10-20', '08:00:00', 'Ear infection', 'completed', '2026-10-01 09:00:00'),
(59, 10, '2026-10-20', '10:30:00', 'Pediatric check', 'completed', '2026-10-01 09:30:00'),
(10, 6, '2026-10-21', '09:00:00', 'General checkup', 'completed', '2026-10-01 10:00:00'),
(21, 13, '2026-10-21', '11:15:00', 'Blood pressure', 'completed', '2026-10-01 10:30:00'),
(31, 19, '2026-10-22', '08:30:00', 'Diabetes review', 'completed', '2026-10-02 08:00:00'),
(41, 21, '2026-10-22', '10:00:00', 'Orthopedic exam', 'completed', '2026-10-02 08:30:00'),
(52, 24, '2026-10-23', '11:00:00', 'Skin rash', 'completed', '2026-10-02 09:00:00'),
(4, 15, '2026-10-23', '12:15:00', 'Cardiac checkup', 'completed', '2026-10-02 09:30:00'),
(16, 8, '2026-10-24', '09:30:00', 'Flu vaccination', 'completed', '2026-10-02 10:00:00'),
(11, 2, '2026-10-24', '11:00:00', 'Routine checkup', 'completed', '2026-10-02 10:30:00'),
(23, 9, '2026-10-25', '09:00:00', 'Back pain', 'completed', '2026-10-02 11:00:00'),
(34, 16, '2026-10-25', '10:15:00', 'Headache', 'completed', '2026-10-02 11:30:00'),
(43, 21, '2026-10-26', '08:30:00', 'Fever', 'completed', '2026-10-03 08:00:00'),
(53, 4, '2026-10-26', '11:45:00', 'Stomach ache', 'completed', '2026-10-03 08:30:00'),
(9, 11, '2026-10-27', '09:15:00', 'Skin allergy', 'completed', '2026-10-03 09:00:00'),
(20, 18, '2026-10-27', '10:30:00', 'Dental pain', 'completed', '2026-10-03 09:30:00'),
(29, 25, '2026-10-28', '12:00:00', 'Eye check', 'completed', '2026-10-03 10:00:00'),
(39, 7, '2026-10-28', '08:15:00', 'Joint swelling', 'completed', '2026-10-04 08:00:00'),
(49, 13, '2026-10-29', '09:45:00', 'Throat pain', 'completed', '2026-10-04 08:30:00'),
(1, 19, '2026-10-29', '11:15:00', 'Chest pain', 'completed', '2026-10-04 09:00:00'),
(13, 3, '2026-10-30', '08:45:00', 'Physical therapy', 'completed', '2026-10-04 09:30:00'),
(24, 15, '2026-10-30', '10:00:00', 'Follow up', 'completed', '2026-10-04 10:00:00'),
(32, 22, '2026-10-31', '09:00:00', 'Dizziness', 'completed', '2026-10-05 08:00:00'),
(44, 6, '2026-10-31', '11:30:00', 'Cough and cold', 'completed', '2026-10-05 08:30:00'),
(54, 12, '2026-11-01', '08:00:00', 'Migraine', 'completed', '2026-10-05 09:00:00'),
(6, 1, '2026-11-01', '10:15:00', 'Ear infection', 'completed', '2026-10-05 09:30:00'),
(17, 10, '2026-11-02', '09:15:00', 'Pediatric check', 'completed', '2026-10-06 08:00:00'),
(27, 17, '2026-11-02', '11:00:00', 'General checkup', 'completed', '2026-10-06 08:30:00'),
(37, 24, '2026-11-03', '08:30:00', 'Blood pressure', 'completed', '2026-10-06 09:00:00'),
(47, 5, '2026-11-03', '10:45:00', 'Diabetes review', 'completed', '2026-10-06 09:30:00'),
(57, 14, '2026-11-04', '11:30:00', 'Orthopedic exam', 'completed', '2026-10-07 08:00:00'),
(9, 20, '2026-11-04', '12:15:00', 'Skin rash', 'cancelled', '2026-10-07 08:30:00'),
(21, 8, '2026-11-05', '09:00:00', 'Cardiac checkup', 'scheduled', '2026-10-07 09:00:00'),
(35, 2, '2026-11-05', '10:30:00', 'Flu vaccination', 'completed', '2026-10-07 09:30:00'),
(15, 3, '2026-11-06', '08:30:00', 'Routine checkup', 'scheduled', '2026-10-07 10:00:00'),
(28, 11, '2026-11-06', '10:00:00', 'Back pain', 'completed', '2026-10-07 10:30:00'),
(42, 19, '2026-11-07', '09:15:00', 'Headache', 'cancelled', '2026-10-08 08:00:00'),
(50, 4, '2026-11-07', '11:30:00', 'Fever', 'no_show', '2026-10-08 08:30:00'),
(12, 22, '2026-11-08', '08:00:00', 'Stomach ache', 'scheduled', '2026-10-08 09:00:00'),
(25, 7, '2026-11-08', '10:15:00', 'Skin allergy', 'completed', '2026-10-08 09:30:00'),
(38, 15, '2026-11-09', '09:00:00', 'Dental pain', 'cancelled', '2026-10-09 08:00:00'),
(55, 1, '2026-11-09', '11:00:00', 'Eye check', 'no_show', '2026-10-09 08:30:00'),
(4, 18, '2026-11-10', '08:45:00', 'Joint swelling', 'scheduled', '2026-10-09 09:00:00'),
(19, 23, '2026-11-10', '12:00:00', 'Throat pain', 'completed', '2026-10-09 09:30:00'),
(33, 9, '2026-11-11', '09:30:00', 'Chest pain', 'cancelled', '2026-10-10 08:00:00'),
(46, 2, '2026-11-11', '11:15:00', 'Physical therapy', 'scheduled', '2026-10-10 08:30:00'),
(8, 14, '2026-11-12', '08:15:00', 'Follow up', 'completed', '2026-10-10 09:00:00'),
(22, 21, '2026-11-12', '10:30:00', 'Dizziness', 'no_show', '2026-10-10 09:30:00'),
(36, 5, '2026-11-13', '09:00:00', 'Cough and cold', 'scheduled', '2026-10-11 08:00:00'),
(48, 12, '2026-11-13', '11:00:00', 'Migraine', 'completed', '2026-10-11 08:30:00'),
(14, 25, '2026-11-14', '08:30:00', 'Ear infection', 'cancelled', '2026-10-11 09:00:00'),
(27, 10, '2026-11-14', '10:15:00', 'Pediatric check', 'scheduled', '2026-10-11 09:30:00'),
(40, 17, '2026-11-15', '09:15:00', 'General checkup', 'completed', '2026-10-12 08:00:00'),
(52, 6, '2026-11-15', '11:45:00', 'Blood pressure', 'no_show', '2026-10-12 08:30:00'),
(3, 20, '2026-11-16', '08:00:00', 'Diabetes review', 'scheduled', '2026-10-12 09:00:00'),
(15, 7, '2026-10-02', '09:00:00', 'Orthopedic exam', 'completed', '2026-10-01 00:00:00'),
(8, 10, '2026-10-03', '09:00:00', 'Skin rash', 'completed', '2026-10-02 00:00:00'),
(10, 14, '2026-10-08', '09:00:00', 'Cardiac checkup', 'completed', '2026-10-07 00:00:00'),
(25, 4, '2026-10-10', '09:00:00', 'Flu vaccination', 'completed', '2026-10-09 00:00:00');

INSERT INTO medical_visits (patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date) VALUES
(3, 2, 1, '2026-10-01', 'Routine checkup', 'Healthy', 'Regular annual checkup completed.', '2027-10-01'),
(5, 4, 2, '2026-10-01', 'Severe headache and nausea', 'Migraine', 'Prescribed pain relievers and rest.', '2026-10-15'),
(12, 1, 3, '2026-10-01', 'High fever and persistent cough', 'Bronchitis', 'Antibiotics and cough syrup prescribed.', '2026-10-10'),
(15, 7, 97, '2026-10-02', 'Sudden chest pain', 'Angina pectoris', 'Urgent ECG performed, referred to cardiology.', '2026-10-05'),
(18, 3, 5, '2026-10-02', 'Lower back pain after lifting', 'Muscle strain', 'Physical therapy sessions recommended.', '2026-10-16'),
(22, 5, 6, '2026-10-02', 'Stomach cramps and indigestion', 'Gastritis', 'Antacids and dietary guidelines given.', '2026-10-12'),
(8, 10, 98, '2026-10-03', 'Itchy red rash on arms', 'Allergic dermatitis', 'Antihistamine cream and pills prescribed.', '2026-10-10'),
(30, 8, 8, '2026-10-03', 'Blurred vision and eye strain', 'Astigmatism', 'Referred to optometrist for glasses.', '2026-11-03'),
(35, 6, 9, '2026-10-04', 'Toothache and gum swelling', 'Dental abscess', 'Painkillers given and scheduled for extraction.', '2026-10-07'),
(40, 10, 11, '2026-10-05', 'Joint stiffness in knees', 'Osteoarthritis', 'Joint supplements and mild exercise advised.', '2026-11-05'),
(3, 1, 12, '2026-10-05', 'Follow-up for general health', 'Stable', 'Blood test results normal.', '2027-04-05'),
(45, 9, 13, '2026-10-05', 'Shortness of breath', 'Asthma exacerbation', 'Inhaler usage adjusted.', '2026-10-19'),
(18, 2, 14, '2026-10-06', 'High blood sugar levels', 'Type 2 Diabetes', 'Adjusted insulin dosage.', '2026-10-20'),
(50, 11, 15, '2026-10-06', 'Ear pain and discharge', 'Otitis media', 'Ear drops prescribed.', '2026-10-13'),
(22, 6, 16, '2026-10-07', 'Severe earache', 'Outer ear infection', 'Antibiotic ear drops given.', '2026-10-14'),
(55, 12, 17, '2026-10-07', 'Sneezing and watery eyes', 'Allergic rhinitis', 'Antihistamines prescribed.', '2026-10-21'),
(10, 14, 99, '2026-10-08', 'Sudden dizziness and fainting', 'Orthostatic hypotension', 'Hydration and salt intake increased.', '2026-10-15'),
(60, 14, 19, '2026-10-08', 'Post-injury stiffness', 'Rehabilitation needed', 'Started physical therapy program.', '2026-10-22'),
(5, 7, 20, '2026-10-09', 'Palpitations', 'Benign arrhythmia', 'Holter monitor attached for 24 hours.', '2026-10-16'),
(40, 15, 21, '2026-10-09', 'Fractured wrist follow-up', 'Healing well', 'Cast removed, light exercises started.', '2026-10-30'),
(25, 4, 100, '2026-10-10', 'High fever and body ache', 'Influenza', 'Bed rest and fluids recommended.', '2026-10-17'),
(35, 13, 23, '2026-10-10', 'Routine physical check', 'Healthy', 'Vitals within normal range.', '2027-10-10'),
(50, 8, 24, '2026-10-11', 'Acne flare-up', 'Acne vulgaris', 'Topical retinoids prescribed.', '2026-11-11'),
(8, 16, 26, '2026-10-12', 'General fatigue', 'Vitamin D deficiency', 'Vitamin D supplements prescribed.', '2026-11-12'),
(15, 4, 27, '2026-10-12', 'Upper back stiffness', 'Myofascial pain', 'Muscle relaxants prescribed.', '2026-10-26'),
(25, 9, 28, '2026-10-13', 'Persistent tension headache', 'Tension headache', 'Stress management and analgesics.', '2026-10-27'),
(33, 2, 29, '2026-10-13', 'Severe sore throat', 'Strep throat', 'Antibiotics prescribed.', '2026-10-20'),
(42, 11, 30, '2026-10-14', 'Nausea and abdominal cramps', 'Gastroenteritis', 'Dietary restrictions and hydration.', '2026-10-21'),
(51, 18, 31, '2026-10-14', 'Dry and flaky skin', 'Eczema', 'Moisturizing creams prescribed.', '2026-10-28'),
(7, 20, 32, '2026-10-15', 'Tooth sensitivity', 'Worn enamel', 'Fluoride treatment applied.', '2026-11-15'),
(19, 22, 33, '2026-10-15', 'Red and watery eyes', 'Conjunctivitis', 'Eye drops prescribed.', '2026-10-22'),
(28, 5, 34, '2026-10-16', 'Swollen ankle joint', 'Sprained ankle', 'RICE protocol and bandage applied.', '2026-10-23'),
(38, 12, 35, '2026-10-16', 'Hoarseness of voice', 'Acute laryngitis', 'Voice rest and steam inhalation.', '2026-10-23'),
(48, 1, 36, '2026-10-17', 'Tightness in chest', 'Anxiety attack', 'Reassurance and breathing exercises.', '2026-10-24'),
(58, 14, 37, '2026-10-17', 'Shoulder mobility issues', 'Frozen shoulder', 'Physiotherapy sessions scheduled.', '2026-10-31'),
(2, 7, 38, '2026-10-18', 'Blood pressure check', 'Hypertension controlled', 'Continue current medication.', '2026-11-18'),
(14, 17, 39, '2026-10-18', 'Frequent dizzy spells', 'Vertigo', 'Medication for motion sickness prescribed.', '2026-10-25'),
(26, 23, 40, '2026-10-19', 'Persistent dry cough', 'Allergic cough', 'Syrup and anti-allergic medication.', '2026-10-26'),
(36, 3, 41, '2026-10-19', 'Severe throbbing headache', 'Migraine attack', 'Triptans prescribed.', '2026-11-02'),
(46, 25, 42, '2026-10-20', 'Blocked ear canal', 'Earwax buildup', 'Wax removal procedure performed.', '2026-11-20'),
(59, 10, 43, '2026-10-20', 'Routine infant checkup', 'Healthy growth', 'Vaccines administered.', '2026-11-20'),
(10, 6, 44, '2026-10-21', 'Annual medical examination', 'Good health', 'Standard lab tests ordered.', '2027-10-21'),
(21, 13, 45, '2026-10-21', 'High blood pressure reading', 'Stage 1 Hypertension', 'Lifestyle modifications advised.', '2026-11-04'),
(31, 19, 46, '2026-10-22', 'Diabetes routine check', 'Stable glucose levels', 'Continue regimen.', '2026-11-22'),
(41, 21, 47, '2026-10-22', 'Knee joint pain', 'Meniscus irritation', 'MRI scan requested.', '2026-11-05'),
(52, 24, 48, '2026-10-23', 'Hives and itching', 'Urticaria', 'Antihistamines given.', '2026-10-30'),
(4, 15, 49, '2026-10-23', 'Chest discomfort on exertion', 'Stable angina', 'Stress test scheduled.', '2026-11-06'),
(16, 8, 50, '2026-10-24', 'Seasonal flu symptoms', 'Influenza', 'Vaccinated and sent home.', '2026-11-24'),
(11, 2, 51, '2026-10-24', 'General weakness', 'Anemia', 'Iron supplements prescribed.', '2026-11-14'),
(23, 9, 52, '2026-10-25', 'Chronic back pain', 'Lumbar spondylosis', 'Physical therapy recommended.', '2026-11-08'),
(34, 16, 53, '2026-10-25', 'Frequent headaches', 'Stress headache', 'Relaxation techniques advised.', '2026-11-08'),
(43, 21, 54, '2026-10-26', 'High fever and chills', 'Viral infection', 'Hydration and paracetamol.', '2026-11-02'),
(53, 4, 55, '2026-10-26', 'Upper abdominal pain', 'Gastric ulcer', 'Gastroscopy scheduled.', '2026-11-09'),
(9, 11, 56, '2026-10-27', 'Skin rash on face', 'Rosacea', 'Topical cream prescribed.', '2026-11-10'),
(20, 18, 57, '2026-10-27', 'Tooth decay pain', 'Caries', 'Filled cavity.', '2026-11-10'),
(29, 25, 58, '2026-10-28', 'Dry itchy eyes', 'Dry eye syndrome', 'Artificial tears prescribed.', '2026-11-11'),
(39, 7, 59, '2026-10-28', 'Wrist swelling', 'Carpal tunnel syndrome', 'Wrist splint recommended.', '2026-11-11'),
(49, 13, 60, '2026-10-29', 'Severe sore throat', 'Pharyngitis', 'Throat lozenges and antibiotics.', '2026-11-05'),
(1, 19, 61, '2026-10-29', 'Chest tightness', 'Mild bronchitis', 'Inhaler prescribed.', '2026-11-12'),
(13, 3, 62, '2026-10-30', 'Post-op knee check', 'Recovery on track', 'Continue exercises.', '2026-11-13'),
(24, 15, 63, '2026-10-30', 'Routine checkup', 'Healthy', 'All clear.', '2027-10-30'),
(32, 22, 64, '2026-10-31', 'Spells of dizziness', 'Benign positional vertigo', 'Epley maneuver performed.', '2026-11-07'),
(44, 6, 65, '2026-10-31', 'Cough and nasal congestion', 'Common cold', 'Rest and fluids.', '2026-11-07'),
(54, 12, 66, '2026-11-01', 'Severe migraine attack', 'Migraine', 'Injection administered.', '2026-11-15'),
(6, 1, 67, '2026-11-01', 'Earache and itching', 'Swimmer ear', 'Ear drops prescribed.', '2026-11-08'),
(17, 10, 68, '2026-11-02', 'Routine pediatric visit', 'Healthy child', 'Vitamins given.', '2027-05-02'),
(27, 17, 69, '2026-11-02', 'General health check', 'Normal', 'No issues found.', '2027-11-02'),
(37, 24, 70, '2026-11-03', 'High blood pressure', 'Hypertension', 'Medication adjusted.', '2026-11-17'),
(47, 5, 71, '2026-11-03', 'Diabetes follow-up', 'Stable', 'Diet plan reviewed.', '2026-12-03'),
(57, 14, 72, '2026-11-04', 'Hip joint pain', 'Bursitis', 'Anti-inflammatory drugs given.', '2026-11-18');

INSERT INTO medicines (medicine_name, manufacturer, unit_price, stock_quantity, minimum_stock, expiry_date, status) VALUES
('Paracetamol 500mg', 'Pfizer', 5.5, 150, 20, '2028-05-12', 'Available'),
('Amoxicillin 250mg', 'Novartis', 12.0, 5, 15, '2027-03-20', 'Available'),
('Aspirin 100mg', 'Bayer', 4.25, 0, 10, '2028-01-15', 'Out of Stock'),
('Ibuprofen 400mg', 'GSK', 8.0, 45, 15, '2025-11-10', 'Expired'),
('Omeprazole 20mg', 'AstraZeneca', 15.5, 80, 10, '2028-08-30', 'Available'),
('Metformin 850mg', 'Sanofi', 9.75, 4, 25, '2027-06-15', 'Available'),
('Atorvastatin 20mg', 'Pfizer', 22.0, 0, 15, '2029-01-10', 'Out of Stock'),
('Lisinopril 10mg', 'Merck', 11.25, 120, 30, '2027-09-12', 'Available'),
('Cetirizine 10mg', 'Johnson & Johnson', 6.5, 12, 20, '2026-05-01', 'Expired'),
('Salbutamol Inhaler', 'Cipla', 18.0, 3, 10, '2026-02-14', 'Expired'),
('Azithromycin 500mg', 'Pfizer', 25.0, 0, 10, '2027-11-05', 'Discontinued'),
('Diclofenac Sodium', 'Novartis', 7.5, 6, 20, '2027-04-18', 'Available'),
('Simvastatin 20mg', 'Bayer', 14.0, 200, 40, '2028-10-10', 'Available'),
('Amlodipine 5mg', 'Sanofi', 10.5, 2, 15, '2027-12-01', 'Available'),
('Pantoprazole 40mg', 'Takeda', 16.8, 0, 10, '2026-08-20', 'Out of Stock'),
('Prednisone 5mg', 'Pfizer', 6.2, 50, 10, '2025-08-15', 'Expired'),
('Losartan 50mg', 'Merck', 13.5, 8, 25, '2027-07-22', 'Available'),
('Levothyroxine 50mcg', 'Abbott', 8.9, 90, 20, '2028-03-11', 'Available'),
('Ciprofloxacin 500mg', 'Bayer', 19.5, 0, 12, '2026-04-30', 'Expired'),
('Clindamycin 300mg', 'Pfizer', 28.0, 15, 10, '2027-01-30', 'Discontinued'),
('Hydrochlorothiazide', 'Novartis', 5.0, 110, 30, '2028-06-19', 'Available'),
('Gabapentin 300mg', 'Pfizer', 24.5, 4, 15, '2027-09-05', 'Available'),
('Meloxicam 15mg', 'Boehringer', 11.0, 0, 20, '2028-02-28', 'Out of Stock'),
('Montelukast 10mg', 'MSD', 21.0, 65, 15, '2027-10-15', 'Available'),
('Sertraline 50mg', 'Pfizer', 17.25, 3, 10, '2026-07-10', 'Expired'),
('Fluoxetine 20mg', 'Eli Lilly', 15.0, 75, 20, '2028-11-20', 'Available'),
('Escitalopram 10mg', 'Forest', 19.8, 0, 15, '2027-05-14', 'Discontinued'),
('Citalopram 20mg', 'Actavis', 12.4, 5, 20, '2027-08-19', 'Available'),
('Clopidogrel 75mg', 'Sanofi', 31.0, 140, 30, '2028-12-05', 'Available'),
('Warfarin 5mg', 'Bristol-Myers', 9.2, 2, 10, '2026-06-30', 'Expired'),
('Spironolactone 25mg', 'Pfizer', 14.5, 40, 15, '2028-01-25', 'Available'),
('Furosemide 40mg', 'Sanofi', 6.8, 0, 25, '2027-03-10', 'Out of Stock'),
('Allopurinol 100mg', 'GSK', 8.5, 85, 20, '2028-04-12', 'Available'),
('Colchicine 0.5mg', 'Takeda', 26.0, 7, 10, '2027-02-18', 'Available'),
('Insulin Glargine', 'Sanofi', 85.0, 0, 10, '2026-05-20', 'Expired'),
('Metronidazole 500mg', 'Pfizer', 10.0, 95, 25, '2028-07-08', 'Available'),
('Doxycycline 100mg', 'Pfizer', 16.5, 4, 15, '2027-09-30', 'Available'),
('Tramadol 50mg', 'Grunenthal', 13.0, 0, 20, '2027-11-11', 'Discontinued'),
('Melatonin 5mg', 'Nature Made', 11.5, 130, 30, '2029-05-15', 'Available'),
('Vitamin D3 1000IU', 'Solgar', 14.2, 6, 25, '2026-03-15', 'Expired');

INSERT INTO prescriptions (visit_id, prescribed_at, notes) VALUES
(1, '2026-10-01 09:30:00', 'Take after meals with plenty of water.'),
(3, '2026-10-01 11:00:00', 'Complete the full course of antibiotics.'),
(5, '2026-10-02 10:15:00', 'Apply topically twice a day.'),
(7, '2026-10-03 08:45:00', 'Take one tablet every 8 hours as needed for pain.'),
(10, '2026-10-05 12:00:00', 'Use eye drops morning and evening.'),
(12, '2026-10-05 09:15:00', 'Strict bed rest for three days.'),
(15, '2026-10-07 10:30:00', 'Take on an empty stomach in the morning.'),
(18, '2026-10-08 11:45:00', 'Use inhaler during shortness of breath episodes.'),
(20, '2026-10-09 09:00:00', 'Check blood sugar levels daily before breakfast.'),
(22, '2026-10-10 10:15:00', 'Take syrup before sleep.'),
(25, '2026-10-12 08:30:00', 'Apply warm compress before ointment.'),
(28, '2026-10-14 11:00:00', 'Avoid dairy products during treatment.'),
(30, '2026-10-15 09:45:00', 'Take with food to avoid stomach irritation.'),
(33, '2026-10-16 12:15:00', 'Complete the 7-day course without interruption.'),
(35, '2026-10-17 08:00:00', 'Take one pill before bedtime.'),
(38, '2026-10-19 10:30:00', 'Gargle with warm salt water three times a day.'),
(40, '2026-10-20 09:15:00', 'Keep affected area clean and dry.'),
(42, '2026-10-21 11:00:00', 'Take painkiller only when pain is severe.'),
(45, '2026-10-22 08:45:00', 'Drink at least 3 liters of water daily.'),
(48, '2026-10-24 10:15:00', 'Take supplement with the main meal.'),
(50, '2026-10-25 09:30:00', 'Rest wrist using a splint at night.'),
(2, '2026-10-12 11:15:00', 'Take one tablet every 12 hours.'),
(4, '2026-10-13 08:30:00', 'Apply cream gently on the affected area.'),
(6, '2026-10-13 10:00:00', 'Take medication with a full glass of water.'),
(9, '2026-10-14 09:00:00', 'Follow low-sodium diet strictly.'),
(11, '2026-10-14 11:30:00', 'Take 30 minutes before breakfast.'),
(14, '2026-10-15 08:15:00', 'Use nasal spray twice daily.'),
(16, '2026-10-15 10:45:00', 'Avoid driving if drowsiness occurs.'),
(19, '2026-10-16 09:15:00', 'Take dose as prescribed by the specialist.'),
(21, '2026-10-16 12:00:00', 'Store medication in a cool, dry place.'),
(24, '2026-10-17 08:30:00', 'Take with meals to enhance absorption.'),
(26, '2026-10-17 10:15:00', 'Complete full prescription duration.'),
(29, '2026-10-18 09:00:00', 'Use eye ointment before sleep.'),
(31, '2026-10-18 11:00:00', 'Take one capsule daily in the morning.'),
(34, '2026-10-19 08:45:00', 'Do not crush or chew the tablets.'),
(37, '2026-10-19 10:30:00', 'Take syrup using the provided measuring cup.'),
(39, '2026-10-20 09:15:00', 'Apply patch on clean, hairless skin.'),
(43, '2026-10-21 11:15:00', 'Take extra vitamin C during treatment.'),
(46, '2026-10-23 08:30:00', 'Avoid direct sunlight while taking this medication.'),
(49, '2026-10-24 10:00:00', 'Take tablet with dinner.'),
(52, '2026-10-26 09:00:00', 'Repeat dosage after 8 hours if needed.'),
(55, '2026-10-27 11:30:00', 'Use ear drops for 5 consecutive days.'),
(58, '2026-10-29 08:15:00', 'Keep medication refrigerated.'),
(60, '2026-10-30 10:45:00', 'Take one tablet every morning on an empty stomach.'),
(63, '2026-10-31 09:30:00', 'Discontinue use if allergic reaction occurs.'),
(65, '2026-11-01 11:00:00', 'Take with plenty of fluids.'),
(67, '2026-11-02 08:30:00', 'Follow up with doctor after finishing prescription.'),
(69, '2026-11-03 10:15:00', 'Take one tablet twice daily after meals.'),
(8, '2026-10-26 09:00:00', 'Rest and avoid strenuous physical activities.'),
(13, '2026-10-26 11:15:00', 'Take medication regularly at the same time every day.');

INSERT INTO prescription_items (prescription_id, medicine_id, dosage, frequency, duration_days, quantity) VALUES
(3, 12, '500mg', 'Twice daily', 7, 14),
(15, 25, '250mg', 'Three times daily', 5, 15),
(42, 8, '100mg', 'Once daily', 30, 30),
(10, 33, '400mg', 'Every 8 hours', 10, 30),
(28, 2, '20mg', 'Once daily', 14, 14),
(49, 19, '850mg', 'Twice daily', 60, 60),
(5, 37, '10mg', 'Once daily', 30, 30),
(33, 14, '500mg', 'Every 12 hours', 7, 14),
(18, 40, '250mg', 'Twice daily', 10, 20),
(22, 6, '50mg', 'Once daily', 30, 30),
(50, 11, '1000mg', 'Single dose', 1, 1),
(1, 23, '10mg', 'Twice daily', 14, 28),
(12, 29, '50mg', 'Once daily', 30, 30),
(39, 4, '400mg', 'Three times daily', 7, 21),
(25, 15, '20mg', 'Once daily', 30, 30),
(8, 30, '5mg', 'Once daily', 14, 14),
(44, 20, '500mg', 'Twice daily', 10, 20),
(16, 7, '300mg', 'Every 8 hours', 5, 15),
(29, 35, '15mg', 'Once daily', 30, 30),
(3, 18, '25mg', 'Twice daily', 14, 28),
(36, 1, '500mg', 'Once daily', 7, 7),
(21, 27, '10mg', 'Every 12 hours', 10, 20),
(47, 9, '20mg', 'Once daily', 30, 30),
(14, 22, '100mg', 'Three times daily', 7, 21),
(30, 38, '50mg', 'Once daily', 30, 30),
(2, 5, '500mg', 'Twice daily', 10, 20),
(11, 16, '250mg', 'Once daily', 30, 30),
(24, 32, '100mg', 'Every 8 hours', 7, 21),
(37, 3, '50mg', 'Once daily', 14, 14),
(45, 21, '400mg', 'Three times daily', 5, 15),
(7, 10, '10mg', 'Once daily', 30, 30),
(19, 28, '20mg', 'Every 12 hours', 10, 20),
(31, 39, '850mg', 'Twice daily', 30, 60),
(43, 13, '500mg', 'Once daily', 7, 7),
(4, 34, '250mg', 'Twice daily', 14, 28),
(13, 26, '100mg', 'Once daily', 30, 30),
(26, 17, '15mg', 'Every 8 hours', 10, 30),
(35, 1, '500mg', 'Twice daily', 7, 14),
(48, 22, '20mg', 'Once daily', 30, 30),
(9, 31, '250mg', 'Three times daily', 5, 15),
(20, 8, '100mg', 'Once daily', 14, 14),
(32, 36, '50mg', 'Every 12 hours', 10, 20),
(41, 12, '400mg', 'Once daily', 30, 30),
(6, 25, '300mg', 'Twice daily', 7, 14),
(17, 33, '10mg', 'Once daily', 30, 30),
(27, 15, '500mg', 'Every 8 hours', 5, 15),
(38, 4, '250mg', 'Twice daily', 14, 28),
(46, 18, '100mg', 'Once daily', 30, 30),
(16, 29, '20mg', 'Twice daily', 10, 20),
(50, 7, '50mg', 'Once daily', 14, 14),
(12, 5, '500mg', 'Twice daily', 10, 20),
(25, 14, '250mg', 'Once daily', 30, 30),
(38, 22, '100mg', 'Every 8 hours', 7, 21),
(45, 3, '50mg', 'Once daily', 14, 14),
(7, 39, '400mg', 'Three times daily', 5, 15),
(19, 11, '10mg', 'Once daily', 30, 30),
(31, 28, '20mg', 'Every 12 hours', 10, 20),
(48, 35, '850mg', 'Twice daily', 30, 60),
(3, 13, '500mg', 'Once daily', 7, 7),
(16, 24, '250mg', 'Twice daily', 14, 28),
(29, 37, '100mg', 'Once daily', 30, 30),
(42, 17, '15mg', 'Every 8 hours', 10, 30),
(10, 1, '500mg', 'Twice daily', 7, 14),
(23, 30, '20mg', 'Once daily', 30, 30),
(36, 12, '250mg', 'Three times daily', 5, 15),
(5, 8, '100mg', 'Once daily', 14, 14),
(18, 40, '50mg', 'Every 12 hours', 10, 20),
(27, 20, '400mg', 'Once daily', 30, 30),
(40, 26, '300mg', 'Twice daily', 7, 14),
(14, 33, '10mg', 'Once daily', 30, 30),
(22, 15, '500mg', 'Every 8 hours', 5, 15),
(34, 4, '250mg', 'Twice daily', 14, 28),
(47, 18, '100mg', 'Once daily', 30, 30),
(9, 29, '20mg', 'Twice daily', 10, 20),
(50, 7, '50mg', 'Once daily', 14, 14),
(4, 15, '500mg', 'Twice daily', 10, 20),
(15, 27, '250mg', 'Once daily', 30, 30),
(28, 33, '100mg', 'Every 8 hours', 7, 21),
(39, 2, '50mg', 'Once daily', 14, 14),
(46, 18, '400mg', 'Three times daily', 5, 15),
(8, 9, '10mg', 'Once daily', 30, 30),
(21, 24, '20mg', 'Every 12 hours', 10, 20),
(32, 35, '850mg', 'Twice daily', 30, 60),
(44, 10, '500mg', 'Once daily', 7, 7),
(2, 29, '250mg', 'Twice daily', 14, 28),
(13, 21, '100mg', 'Once daily', 30, 30),
(26, 16, '15mg', 'Every 8 hours', 10, 30),
(37, 3, '500mg', 'Twice daily', 7, 14),
(49, 23, '20mg', 'Once daily', 30, 30),
(6, 31, '250mg', 'Three times daily', 5, 15),
(19, 7, '100mg', 'Once daily', 14, 14),
(30, 38, '50mg', 'Every 12 hours', 10, 20),
(41, 12, '400mg', 'Once daily', 30, 30),
(11, 26, '300mg', 'Twice daily', 7, 14),
(24, 34, '10mg', 'Once daily', 30, 30),
(35, 14, '500mg', 'Every 8 hours', 5, 15),
(47, 5, '250mg', 'Twice daily', 14, 28),
(9, 19, '100mg', 'Once daily', 30, 30),
(22, 28, '20mg', 'Twice daily', 10, 20),
(50, 6, '50mg', 'Once daily', 14, 14),
(5, 12, '500mg', 'Twice daily', 10, 20),
(12, 25, '250mg', 'Once daily', 30, 30),
(22, 33, '100mg', 'Every 8 hours', 7, 21),
(34, 4, '50mg', 'Once daily', 14, 14),
(45, 18, '400mg', 'Three times daily', 5, 15),
(3, 9, '10mg', 'Once daily', 30, 30),
(17, 24, '20mg', 'Every 12 hours', 10, 20),
(29, 35, '850mg', 'Twice daily', 30, 60),
(41, 10, '500mg', 'Once daily', 7, 7),
(50, 29, '250mg', 'Twice daily', 14, 28),
(8, 21, '100mg', 'Once daily', 30, 30),
(19, 16, '15mg', 'Every 8 hours', 10, 30),
(31, 3, '500mg', 'Twice daily', 7, 14),
(43, 23, '20mg', 'Once daily', 30, 30),
(1, 31, '250mg', 'Three times daily', 5, 15),
(14, 7, '100mg', 'Once daily', 14, 14),
(27, 38, '50mg', 'Every 12 hours', 10, 20),
(39, 12, '400mg', 'Once daily', 30, 30),
(48, 26, '300mg', 'Twice daily', 7, 14),
(25, 40, '10mg', 'Once daily', 14, 14);

INSERT INTO lab_tests (test_name, category, price, normal_range, status) VALUES
('Complete Blood Count (CBC)', 'Hematology', 15.0, '4.5-11.0 10^3/uL', 'Active'),
('Fast Blood Glucose', 'Biochemistry', 10.0, '70-99 mg/dL', 'Active'),
('Lipid Profile', 'Biochemistry', 25.0, 'Desirable < 200 mg/dL', 'Active'),
('Liver Function Test (LFT)', 'Biochemistry', 30.0, 'Various ranges', 'Active'),
('Kidney Function Test (KFT)', 'Biochemistry', 28.0, 'Various ranges', 'Active'),
('Thyroid Stimulating Hormone (TSH)', 'Endocrinology', 35.0, '0.4-4.0 mIU/L', 'Active'),
('Hemoglobin A1c (HbA1c)', 'Biochemistry', 22.0, '< 5.7 %', 'Active'),
('Urinalysis', 'Pathology', 12.5, 'Negative for protein/glucose', 'Active'),
('Prothrombin Time (PT/INR)', 'Hematology', 18.0, '11.0-13.5 sec', 'Inactive'),
('Vitamin D 25-Hydroxy', 'Endocrinology', 45.0, '30-100 ng/mL', 'Active'),
('C-Reactive Protein (CRP)', 'Immunology', 20.0, '< 3.0 mg/L', 'Active'),
('Erythrocyte Sedimentation Rate (ESR)', 'Hematology', 14.0, '0-22 mm/hr', 'Inactive'),
('Serum Electrolytes', 'Biochemistry', 24.0, 'Na: 135-145, K: 3.5-5.0', 'Active'),
('Hepatitis B Surface Antigen', 'Virology', 30.0, 'Non-Reactive', 'Discontinued'),
('HIV 1/2 Antibody', 'Virology', 40.0, 'Non-Reactive', 'Active'),
('Pregnancy Test (Serum)', 'Endocrinology', 15.0, 'Negative', 'Active'),
('Stool Analysis', 'Pathology', 12.0, 'No parasites detected', 'Inactive'),
('Iron Panel', 'Biochemistry', 35.0, '60-170 mcg/dL', 'Active'),
('Rheumatoid Factor (RF)', 'Immunology', 22.0, '< 14 IU/mL', 'Discontinued'),
('PSA (Prostate Specific Antigen)', 'Endocrinology', 40.0, '< 4.0 ng/mL', 'Active'),
('Blood Typing (ABO/Rh)', 'Hematology', 10.0, 'Positive/Negative', 'Active'),
('Magnesium Serum', 'Biochemistry', 18.5, '1.7-2.2 mg/dL', 'Inactive'),
('Calcium Serum', 'Biochemistry', 16.0, '8.5-10.2 mg/dL', 'Active'),
('Uric Acid', 'Biochemistry', 14.0, '3.4-7.0 mg/dL', 'Active'),
('Troponin I', 'Cardiology', 50.0, '< 0.04 ng/mL', 'Discontinued');

INSERT INTO patient_lab_tests (visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status) VALUES
(5, 2, '2026-10-02 09:00:00', '2026-10-02 10:30:00', 'Hemoglobin: 14.2 g/dL', 'Normal', 'completed'),
(12, 5, '2026-10-05 09:00:00', NULL, 'Pending review', 'Pending', 'ordered'),
(20, 1, '2026-10-09 09:00:00', '2026-10-09 12:15:00', 'WBC: 7.5 10^3/uL', 'Normal', 'completed'),
(35, 10, '2026-10-17 09:00:00', NULL, 'In progress result', 'Pending', 'processing'),
(45, 15, '2026-10-22 09:00:00', '2026-10-22 10:30:00', 'Negative', 'Normal', 'completed'),
(8, 22, '2026-10-03 11:15:00', '2026-10-03 11:45:00', 'Cancelled by doctor', 'N/A', 'cancelled'),
(50, 3, '2026-10-25 09:00:00', '2026-10-25 12:30:00', 'Total Cholesterol: 190 mg/dL', 'Normal', 'completed'),
(15, 8, '2026-10-07 09:00:00', '2026-10-07 10:30:00', 'Clear yellow, Protein negative', 'Normal', 'completed'),
(62, 12, '2026-10-31 09:00:00', NULL, 'Sample collected', 'Pending', 'processing'),
(3, 20, '2026-10-05 09:30:00', '2026-10-05 14:00:00', 'PSA: 2.1 ng/mL', 'Normal', 'completed'),
(25, 7, '2026-10-12 09:00:00', '2026-10-12 11:20:00', 'HbA1c: 5.4%', 'Normal', 'completed'),
(33, 18, '2026-10-16 09:00:00', NULL, 'Awaiting processing', 'Pending', 'ordered'),
(55, 4, '2026-10-27 09:00:00', '2026-10-27 14:00:00', 'ALT: 25, AST: 22 U/L', 'Normal', 'completed'),
(18, 9, '2026-10-08 09:00:00', '2026-10-08 09:30:00', 'Sample rejected', 'N/A', 'cancelled'),
(40, 11, '2026-10-20 09:00:00', '2026-10-20 11:15:00', 'CRP: 2.1 mg/L', 'Normal', 'completed'),
(68, 25, '2026-11-03 09:00:00', '2026-11-03 10:30:00', 'Troponin: 0.01 ng/mL', 'Normal', 'completed'),
(10, 6, '2026-10-09 08:20:00', NULL, 'Processing', 'Pending', 'processing'),
(28, 14, '2026-10-14 09:00:00', '2026-10-14 10:50:00', 'ESR: 12 mm/hr', 'Normal', 'completed'),
(42, 17, '2026-10-21 09:00:00', '2026-10-21 10:30:00', 'Stool normal', 'Normal', 'completed'),
(58, 21, '2026-10-29 09:00:00', NULL, 'New order', 'Pending', 'ordered'),
(7, 13, '2026-10-11 08:30:00', '2026-10-11 11:00:00', 'Na: 140, K: 4.2', 'Normal', 'completed'),
(22, 19, '2026-10-11 09:30:00', '2026-10-11 10:00:00', 'Cancelled test', 'N/A', 'cancelled'),
(36, 23, '2026-10-18 09:00:00', '2026-10-18 10:45:00', 'Calcium: 9.4 mg/dL', 'Normal', 'completed'),
(49, 24, '2026-10-24 09:00:00', '2026-10-24 10:45:00', 'Uric Acid: 5.2 mg/dL', 'Normal', 'completed'),
(60, 1, '2026-10-30 09:00:00', NULL, 'Sample in lab', 'Pending', 'processing'),
(14, 4, '2026-10-13 09:00:00', '2026-10-13 11:00:00', 'Normal levels', 'Normal', 'completed'),
(23, 12, '2026-10-14 08:30:00', NULL, 'Pending review', 'Pending', 'ordered'),
(31, 7, '2026-10-15 09:00:00', '2026-10-15 11:30:00', 'Glucose: 95 mg/dL', 'Normal', 'completed'),
(44, 16, '2026-10-22 09:00:00', NULL, 'In progress', 'Pending', 'processing'),
(52, 2, '2026-10-26 09:00:00', '2026-10-26 10:30:00', 'Negative', 'Normal', 'completed'),
(61, 19, '2026-10-30 09:00:00', '2026-10-30 09:30:00', 'Cancelled by patient', 'N/A', 'cancelled'),
(4, 9, '2026-10-16 10:15:00', '2026-10-16 13:00:00', 'Cholesterol: 180 mg/dL', 'Normal', 'completed'),
(19, 15, '2026-10-17 08:30:00', '2026-10-17 10:00:00', 'Clear', 'Normal', 'completed'),
(37, 21, '2026-10-18 09:00:00', NULL, 'Sample processing', 'Pending', 'processing'),
(48, 5, '2026-10-24 09:00:00', '2026-10-24 13:00:00', 'TSH: 2.5 mIU/L', 'Normal', 'completed'),
(11, 22, '2026-10-18 08:45:00', '2026-10-18 10:30:00', 'HbA1c: 5.6%', 'Normal', 'completed'),
(26, 11, '2026-10-19 09:15:00', NULL, 'Ordered test', 'Pending', 'ordered'),
(39, 13, '2026-10-19 10:30:00', '2026-10-19 14:00:00', 'ALT: 20 U/L', 'Normal', 'completed'),
(53, 8, '2026-10-26 09:00:00', '2026-10-26 09:30:00', 'Rejected sample', 'N/A', 'cancelled'),
(65, 1, '2026-11-01 09:00:00', '2026-11-01 11:15:00', 'CRP: 1.5 mg/L', 'Normal', 'completed'),
(9, 18, '2026-10-21 08:30:00', '2026-10-21 10:00:00', 'Troponin: normal', 'Normal', 'completed'),
(21, 24, '2026-10-21 09:45:00', NULL, 'Processing state', 'Pending', 'processing'),
(34, 10, '2026-10-22 08:00:00', '2026-10-22 10:00:00', 'ESR: 10 mm/hr', 'Normal', 'completed'),
(46, 17, '2026-10-23 09:00:00', '2026-10-23 10:30:00', 'Stool sample normal', 'Normal', 'completed'),
(57, 25, '2026-10-28 09:00:00', NULL, 'New lab order', 'Pending', 'ordered'),
(13, 6, '2026-10-23 09:00:00', '2026-10-23 11:45:00', 'Electrolytes normal', 'Normal', 'completed'),
(29, 20, '2026-10-24 08:30:00', '2026-10-24 09:00:00', 'Cancelled order', 'N/A', 'cancelled'),
(41, 14, '2026-10-24 10:00:00', '2026-10-24 11:30:00', 'Calcium: 9.2 mg/dL', 'Normal', 'completed'),
(56, 3, '2026-10-28 09:00:00', '2026-10-28 11:00:00', 'Uric acid normal', 'Normal', 'completed'),
(67, 9, '2026-11-02 09:00:00', NULL, 'Lab in progress', 'Pending', 'processing'),
(15, 12, '2026-10-26 08:00:00', '2026-10-26 10:00:00', 'Normal', 'Normal', 'completed'),
(32, 5, '2026-10-26 09:15:00', NULL, 'Pending check', 'Pending', 'ordered'),
(48, 18, '2026-10-27 08:30:00', '2026-10-27 12:00:00', 'Glucose: 110 mg/dL', 'Normal', 'completed'),
(65, 2, '2026-11-01 09:00:00', NULL, 'Processing test', 'Pending', 'processing'),
(10, 22, '2026-10-28 08:00:00', '2026-10-28 09:30:00', 'Negative', 'Normal', 'completed'),
(27, 9, '2026-10-28 11:00:00', '2026-10-28 11:45:00', 'Cancelled by physician', 'N/A', 'cancelled'),
(42, 14, '2026-10-29 08:15:00', '2026-10-29 11:00:00', 'Cholesterol: 210 mg/dL', 'Normal', 'completed'),
(55, 3, '2026-10-29 09:30:00', '2026-10-29 10:45:00', 'Urine clear', 'Normal', 'completed'),
(6, 20, '2026-10-30 08:00:00', NULL, 'Sample collected', 'Pending', 'processing'),
(19, 7, '2026-10-30 10:00:00', '2026-10-30 13:00:00', 'PSA: 1.8 ng/mL', 'Normal', 'completed'),
(38, 11, '2026-10-31 08:30:00', '2026-10-31 10:00:00', 'HbA1c: 5.8%', 'Normal', 'completed'),
(50, 25, '2026-10-31 09:45:00', NULL, 'New request', 'Pending', 'ordered'),
(68, 16, '2026-11-03 09:00:00', '2026-11-03 13:30:00', 'ALT: 30 U/L', 'Normal', 'completed'),
(12, 4, '2026-11-01 09:15:00', '2026-11-01 09:45:00', 'Sample rejected', 'N/A', 'cancelled'),
(29, 13, '2026-11-02 08:30:00', '2026-11-02 10:45:00', 'CRP: 1.2 mg/L', 'Normal', 'completed'),
(44, 8, '2026-11-02 11:00:00', '2026-11-02 12:30:00', 'Troponin: 0.02', 'Normal', 'completed'),
(59, 1, '2026-11-03 08:20:00', NULL, 'In laboratory', 'Pending', 'processing'),
(21, 19, '2026-11-03 09:50:00', '2026-11-03 11:40:00', 'ESR: 15 mm/hr', 'Normal', 'completed'),
(35, 23, '2026-11-04 08:00:00', '2026-11-04 09:30:00', 'Stool test normal', 'Normal', 'completed'),
(49, 6, '2026-11-04 10:15:00', NULL, 'Order logged', 'Pending', 'ordered'),
(63, 15, '2026-11-05 08:30:00', '2026-11-05 11:00:00', 'Na: 138, K: 4.1', 'Normal', 'completed'),
(8, 10, '2026-11-05 09:30:00', '2026-11-05 10:00:00', 'Cancelled request', 'N/A', 'cancelled'),
(24, 21, '2026-11-06 08:00:00', '2026-11-06 09:45:00', 'Calcium: 9.5 mg/dL', 'Normal', 'completed'),
(41, 17, '2026-11-06 10:30:00', '2026-11-06 12:15:00', 'Uric acid: 5.0', 'Normal', 'completed'),
(57, 24, '2026-11-07 08:15:00', NULL, 'Processing sample', 'Pending', 'processing'),
(14, 18, '2026-11-08 08:00:00', '2026-11-08 10:30:00', 'Normal ranges', 'Normal', 'completed'),
(31, 3, '2026-11-08 09:15:00', NULL, 'Pending review', 'Pending', 'ordered'),
(45, 11, '2026-11-09 08:30:00', '2026-11-09 12:00:00', 'Glucose: 98 mg/dL', 'Normal', 'completed'),
(60, 22, '2026-11-09 10:00:00', NULL, 'Processing sample', 'Pending', 'processing'),
(5, 7, '2026-11-10 08:00:00', '2026-11-10 09:30:00', 'Negative result', 'Normal', 'completed'),
(22, 14, '2026-11-10 11:00:00', '2026-11-10 11:45:00', 'Cancelled by doctor', 'N/A', 'cancelled'),
(39, 25, '2026-11-11 08:15:00', '2026-11-11 11:00:00', 'Lipid profile normal', 'Normal', 'completed'),
(52, 9, '2026-11-11 09:30:00', '2026-11-11 10:45:00', 'Urine test clean', 'Normal', 'completed'),
(11, 2, '2026-11-12 08:00:00', NULL, 'Sample collected', 'Pending', 'processing'),
(28, 19, '2026-11-12 10:00:00', '2026-11-12 13:00:00', 'PSA: 2.0 ng/mL', 'Normal', 'completed'),
(43, 12, '2026-11-13 08:30:00', '2026-11-13 10:00:00', 'HbA1c: 5.5%', 'Normal', 'completed'),
(58, 4, '2026-11-13 09:45:00', NULL, 'New order logged', 'Pending', 'ordered'),
(67, 16, '2026-11-14 08:00:00', '2026-11-14 12:30:00', 'ALT: 28 U/L', 'Normal', 'completed'),
(7, 23, '2026-11-14 09:15:00', '2026-11-14 09:45:00', 'Sample rejected', 'N/A', 'cancelled'),
(24, 8, '2026-11-15 08:30:00', '2026-11-15 10:45:00', 'CRP: 1.0 mg/L', 'Normal', 'completed'),
(36, 20, '2026-11-15 11:00:00', '2026-11-15 12:30:00', 'Troponin: normal', 'Normal', 'completed'),
(51, 1, '2026-11-16 08:20:00', NULL, 'Lab in progress', 'Pending', 'processing'),
(18, 13, '2026-11-16 09:50:00', '2026-11-16 11:40:00', 'ESR: 10 mm/hr', 'Normal', 'completed'),
(33, 17, '2026-11-17 08:00:00', '2026-11-17 09:30:00', 'Stool test normal', 'Normal', 'completed'),
(47, 6, '2026-11-17 10:15:00', NULL, 'Order registered', 'Pending', 'ordered'),
(62, 21, '2026-11-18 08:30:00', '2026-11-18 11:00:00', 'Na: 140, K: 4.0', 'Normal', 'completed'),
(4, 15, '2026-11-18 09:30:00', '2026-11-18 10:00:00', 'Cancelled request', 'N/A', 'cancelled'),
(20, 10, '2026-11-19 08:00:00', '2026-11-19 09:45:00', 'Calcium: 9.3 mg/dL', 'Normal', 'completed'),
(38, 24, '2026-11-19 10:30:00', '2026-11-19 12:15:00', 'Uric acid: 5.4', 'Normal', 'completed'),
(55, 5, '2026-11-20 08:15:00', NULL, 'Processing sample', 'Pending', 'processing');

INSERT INTO admissions (patient_id, room_id, doctor_id, admitted_at, discharged_at, admission_reason, status) VALUES
(5, 10, 3, '2026-10-01 08:00:00', '2026-10-05 14:00:00', 'Acute Appendicitis', 'discharged'),
(12, 22, 7, '2026-10-02 09:30:00', '2026-10-10 10:00:00', 'Severe Pneumonia', 'discharged'),
(25, 5, 15, '2026-10-03 14:00:00', '2026-10-04 12:00:00', 'Hypertensive Crisis', 'discharged'),
(40, 18, 2, '2026-10-04 11:15:00', '2026-10-04 16:30:00', 'Scheduled Surgery Admission - Cancelled', 'cancelled'),
(3, 1, 20, '2026-10-05 07:30:00', '2026-10-12 09:00:00', 'Myocardial Infarction', 'discharged'),
(50, 14, 11, '2026-10-06 10:00:00', '2026-10-15 11:30:00', 'Type 2 Diabetes Complications', 'discharged'),
(18, 25, 9, '2026-10-07 12:30:00', '2026-10-14 15:00:00', 'Asthma Exacerbation', 'discharged'),
(33, 8, 4, '2026-10-08 08:15:00', '2026-10-08 13:00:00', 'Patient requested discharge against medical advice', 'cancelled'),
(60, 30, 22, '2026-10-09 15:00:00', '2026-10-20 10:00:00', 'Bone Fracture Recovery', 'discharged'),
(22, 12, 1, '2026-10-10 09:00:00', '2026-10-18 14:00:00', 'Gastroenteritis', 'discharged'),
(7, 19, 13, '2026-10-11 16:20:00', '2026-10-25 11:00:00', 'Severe Burn Injury', 'discharged'),
(45, 3, 18, '2026-10-12 11:00:00', '2026-10-12 14:00:00', 'Administrative cancellation', 'cancelled'),
(14, 27, 6, '2026-10-13 08:30:00', '2026-10-19 12:00:00', 'Kidney Stones', 'discharged'),
(31, 9, 25, '2026-10-14 10:45:00', '2026-10-22 09:30:00', 'Viral Meningitis', 'discharged'),
(58, 21, 10, '2026-10-15 13:10:00', '2026-10-28 16:00:00', 'Stroke Rehabilitation', 'discharged'),
(2, 16, 14, '2026-10-16 07:00:00', '2026-10-16 11:00:00', 'Duplicate booking cancellation', 'cancelled'),
(29, 4, 19, '2026-10-17 14:30:00', '2026-10-24 10:00:00', 'Cellulitis Treatment', 'discharged'),
(36, 28, 5, '2026-10-18 09:15:00', '2026-11-02 12:00:00', 'Post-operative Care', 'discharged'),
(11, 11, 21, '2026-10-19 11:00:00', '2026-10-30 09:00:00', 'Appendectomy Recovery', 'discharged'),
(52, 20, 8, '2026-10-20 08:00:00', '2026-10-20 12:30:00', 'Patient transfer error - cancelled', 'cancelled'),
(20, 6, 12, '2026-10-21 10:00:00', '2026-10-29 15:00:00', 'Bacterial Infection', 'discharged'),
(39, 23, 17, '2026-10-22 15:30:00', '2026-11-05 11:00:00', 'Chronic Heart Failure', 'discharged'),
(8, 15, 3, '2026-10-23 09:45:00', '2026-11-01 10:30:00', 'Pancreatitis', 'discharged'),
(55, 2, 24, '2026-10-24 12:00:00', '2026-10-24 17:00:00', 'Bed availability issue - cancelled', 'cancelled'),
(16, 26, 16, '2026-10-25 08:30:00', '2026-11-03 14:00:00', 'Cholecystitis', 'discharged'),
(34, 13, 2, '2026-10-26 10:15:00', NULL, 'Deep Vein Thrombosis under observation', 'admitted'),
(48, 29, 9, '2026-10-27 11:00:00', NULL, 'Severe Migraine Ongoing Treatment', 'admitted'),
(24, 7, 23, '2026-10-28 14:00:00', '2026-10-28 18:00:00', 'Family request cancellation', 'cancelled'),
(41, 17, 11, '2026-10-29 09:00:00', NULL, 'Pneumothorax Active Care', 'admitted'),
(19, 24, 15, '2026-10-30 08:00:00', NULL, 'General Trauma Recovery Ward', 'admitted');

INSERT INTO insurance_companies (company_name, phone, email, coverage_percentage, status) VALUES
('Global Insurance Co.', '+1-800-555-0199', 'info@globalins.com', 80.0, 'Active'),
('SafeLife Health Care', '+1-800-555-0288', 'support@safelife.com', 75.5, 'Active'),
('MedGuard Assurance', '+1-800-555-0377', 'contact@medguard.net', 90.0, 'Inactive'),
('Prime Care Insurance', '+1-800-555-0466', 'help@primecare.org', 60.0, 'Active'),
('Trustworthy Health Plan', '+1-800-555-0555', 'service@trustworthy.com', 85.0, 'Inactive');

INSERT INTO patient_insurance (patient_id, insurance_company_id, policy_number, start_date, expiry_date, status) VALUES
(5, 2, 'POL-98210', '2025-01-01', '2026-01-01', 'Expired'),
(12, 1, 'POL-44125', '2026-01-15', '2027-01-15', 'Active'),
(24, 3, 'POL-77839', '2025-06-01', '2025-12-01', 'Cancelled'),
(35, 4, 'POL-11923', '2026-03-01', '2027-03-01', 'Active'),
(48, 5, 'POL-55648', '2024-02-10', '2025-02-10', 'Expired'),
(3, 2, 'POL-33214', '2026-02-01', '2027-02-01', 'Active'),
(15, 1, 'POL-88912', '2025-04-10', '2026-04-10', 'Expired'),
(29, 3, 'POL-66523', '2026-05-12', '2027-05-12', 'Active'),
(42, 4, 'POL-12345', '2025-03-15', '2025-09-15', 'Cancelled'),
(55, 5, 'POL-99876', '2026-06-01', '2027-06-01', 'Active'),
(8, 1, 'POL-23456', '2024-01-01', '2025-01-01', 'Expired'),
(19, 2, 'POL-34567', '2026-04-01', '2027-04-01', 'Active'),
(31, 3, 'POL-45678', '2025-05-20', '2025-11-20', 'Cancelled'),
(45, 4, 'POL-56789', '2026-07-01', '2027-07-01', 'Active'),
(58, 5, 'POL-67890', '2023-11-10', '2024-11-10', 'Expired'),
(1, 2, 'POL-11122', '2026-01-10', '2027-01-10', 'Active'),
(14, 3, 'POL-22233', '2025-08-01', '2026-02-01', 'Cancelled'),
(27, 4, 'POL-33344', '2026-02-15', '2027-02-15', 'Active'),
(38, 5, 'POL-44455', '2024-06-01', '2025-06-01', 'Expired'),
(50, 1, 'POL-55566', '2026-03-20', '2027-03-20', 'Active'),
(7, 3, 'POL-66677', '2025-09-10', '2026-03-10', 'Cancelled'),
(22, 4, 'POL-77788', '2026-04-10', '2027-04-10', 'Active'),
(33, 5, 'POL-88899', '2024-05-15', '2025-05-15', 'Expired'),
(46, 1, 'POL-99900', '2026-05-01', '2027-05-01', 'Active'),
(59, 2, 'POL-12131', '2025-07-15', '2025-12-31', 'Cancelled'),
(4, 4, 'POL-14151', '2026-06-10', '2027-06-10', 'Active'),
(17, 5, 'POL-16171', '2024-08-20', '2025-08-20', 'Expired'),
(28, 1, 'POL-18192', '2026-01-25', '2027-01-25', 'Active'),
(39, 2, 'POL-20212', '2025-02-10', '2025-08-10', 'Cancelled'),
(53, 3, 'POL-22232', '2026-02-28', '2027-02-28', 'Active'),
(10, 5, 'POL-24252', '2023-12-01', '2024-12-01', 'Expired'),
(21, 1, 'POL-26272', '2026-03-15', '2027-03-15', 'Active'),
(32, 2, 'POL-28293', '2025-04-05', '2025-10-05', 'Cancelled'),
(44, 3, 'POL-30313', '2026-04-20', '2027-04-20', 'Active'),
(57, 4, 'POL-32333', '2024-09-10', '2025-09-10', 'Expired'),
(6, 2, 'POL-34353', '2026-05-10', '2027-05-10', 'Active'),
(18, 3, 'POL-36373', '2025-06-15', '2025-12-15', 'Cancelled'),
(30, 4, 'POL-38393', '2026-06-25', '2027-06-25', 'Active'),
(41, 5, 'POL-40414', '2024-10-01', '2025-10-01', 'Expired'),
(56, 1, 'POL-42434', '2026-07-10', '2027-07-10', 'Active');

INSERT INTO invoices (patient_id, visit_id, admission_id, subtotal, insurance_discount, total_amount, issued_at, due_date, payment_status) VALUES
(5, 2, 1, 250.0, 50.0, 200.0, '2026-10-01 08:00:00', '2026-10-15 08:00:00', 'unpaid'),
(12, 3, 2, 450.0, 100.0, 350.0, '2026-10-02 09:30:00', '2026-10-16 09:30:00', 'paid'),
(24, 61, NULL, 600.0, 150.0, 450.0, '2026-10-30 08:00:00', '2026-11-13 08:00:00', 'unpaid'),
(35, 22, NULL, 120.0, 20.0, 100.0, '2026-10-10 08:00:00', '2026-10-24 08:00:00', 'paid'),
(48, 34, 27, 800.0, 200.0, 600.0, '2026-10-27 11:00:00', '2026-11-10 11:00:00', 'partially_paid'),
(3, 11, 5, 300.0, 50.0, 250.0, '2026-10-06 09:00:00', '2026-10-20 09:00:00', 'unpaid'),
(15, 4, NULL, 150.0, 30.0, 120.0, '2026-10-07 10:30:00', '2026-10-21 10:30:00', 'unpaid'),
(29, 56, 17, 950.0, 250.0, 700.0, '2026-10-28 08:00:00', '2026-11-11 08:00:00', 'partially_paid'),
(42, 28, NULL, 500.0, 100.0, 400.0, '2026-10-14 08:00:00', '2026-10-28 08:00:00', 'paid'),
(55, 16, NULL, 400.0, 80.0, 320.0, '2026-10-10 14:00:00', '2026-10-24 14:00:00', 'paid'),
(8, 7, 23, 220.0, 20.0, 200.0, '2026-10-23 09:45:00', '2026-11-06 09:45:00', 'unpaid'),
(19, 31, 30, 750.0, 150.0, 600.0, '2026-10-30 08:00:00', '2026-11-13 08:00:00', 'paid'),
(31, 44, 14, 350.0, 50.0, 300.0, '2026-10-22 08:00:00', '2026-11-05 08:00:00', 'unpaid'),
(45, 12, NULL, 1100.0, 300.0, 800.0, '2026-10-14 11:00:00', '2026-10-28 11:00:00', 'partially_paid'),
(58, 35, 15, 180.0, 30.0, 150.0, '2026-10-17 08:00:00', '2026-10-31 08:00:00', 'paid'),
(1, 59, NULL, 550.0, 100.0, 450.0, '2026-10-29 08:00:00', '2026-11-12 08:00:00', 'unpaid'),
(14, 37, 13, 290.0, 40.0, 250.0, '2026-10-18 08:00:00', '2026-11-01 08:00:00', 'paid'),
(27, 67, NULL, 620.0, 120.0, 500.0, '2026-11-02 08:00:00', '2026-11-16 08:00:00', 'unpaid'),
(38, 33, NULL, 410.0, 60.0, 350.0, '2026-10-19 11:30:00', '2026-11-02 11:30:00', 'paid'),
(50, 14, 6, 850.0, 200.0, 650.0, '2026-10-20 13:00:00', '2026-11-03 13:00:00', 'partially_paid'),
(7, 30, 11, 330.0, 30.0, 300.0, '2026-10-21 08:30:00', '2026-11-04 08:30:00', 'unpaid'),
(22, 15, 10, 490.0, 90.0, 400.0, '2026-10-22 09:00:00', '2026-11-05 09:00:00', 'paid'),
(33, 27, NULL, 710.0, 110.0, 600.0, '2026-10-23 10:15:00', '2026-11-06 10:15:00', 'paid'),
(46, 40, NULL, 230.0, 30.0, 200.0, '2026-10-24 11:45:00', '2026-11-07 11:45:00', 'paid'),
(59, 41, NULL, 920.0, 220.0, 700.0, '2026-10-25 12:30:00', '2026-11-08 12:30:00', 'paid'),
(4, 47, NULL, 380.0, 80.0, 300.0, '2026-10-26 08:00:00', '2026-11-09 08:00:00', 'paid'),
(17, 66, NULL, 540.0, 90.0, 450.0, '2026-11-02 08:00:00', '2026-11-16 08:00:00', 'paid'),
(28, 32, NULL, 670.0, 170.0, 500.0, '2026-10-28 10:10:00', '2026-11-11 10:10:00', 'partially_paid'),
(39, 57, 22, 260.0, 60.0, 200.0, '2026-10-29 11:00:00', '2026-11-12 11:00:00', 'paid'),
(53, 53, NULL, 810.0, 210.0, 600.0, '2026-10-30 14:00:00', '2026-11-13 14:00:00', 'partially_paid'),
(10, 17, NULL, 430.0, 80.0, 350.0, '2026-10-31 08:15:00', '2026-11-14 08:15:00', 'paid'),
(21, 43, NULL, 310.0, 60.0, 250.0, '2026-11-01 09:30:00', '2026-11-15 09:30:00', 'paid'),
(32, 62, NULL, 590.0, 90.0, 500.0, '2026-11-02 10:00:00', '2026-11-16 10:00:00', 'unpaid'),
(44, 63, NULL, 720.0, 120.0, 600.0, '2026-11-03 11:15:00', '2026-11-17 11:15:00', 'unpaid'),
(57, 70, NULL, 480.0, 80.0, 400.0, '2026-11-04 12:00:00', '2026-11-18 12:00:00', 'cancelled'),
(6, 65, NULL, 240.0, 40.0, 200.0, '2026-11-05 08:00:00', '2026-11-19 08:00:00', 'paid'),
(18, 5, 7, 660.0, 160.0, 500.0, '2026-11-06 09:10:00', '2026-11-20 09:10:00', 'partially_paid'),
(30, 8, NULL, 390.0, 90.0, 300.0, '2026-11-07 10:30:00', '2026-11-21 10:30:00', 'unpaid'),
(41, 45, 29, 530.0, 80.0, 450.0, '2026-11-08 11:20:00', '2026-11-22 11:20:00', 'partially_paid'),
(8, 24, 23, 880.0, 180.0, 700.0, '2026-11-09 13:00:00', '2026-11-23 13:00:00', 'partially_paid'),
(2, 36, NULL, 270.0, 20.0, 250.0, '2026-11-10 08:30:00', '2026-11-24 08:30:00', 'paid'),
(13, 60, NULL, 440.0, 90.0, 350.0, '2026-11-11 09:45:00', '2026-11-25 09:45:00', 'paid'),
(25, 21, 3, 610.0, 110.0, 500.0, '2026-11-12 10:15:00', '2026-11-26 10:15:00', 'partially_paid'),
(37, 68, NULL, 360.0, 60.0, 300.0, '2026-11-13 11:00:00', '2026-11-27 11:00:00', 'paid'),
(49, 58, NULL, 790.0, 190.0, 600.0, '2026-11-14 12:30:00', '2026-11-28 12:30:00', 'paid'),
(9, 54, NULL, 340.0, 40.0, 300.0, '2026-11-15 08:00:00', '2026-11-29 08:00:00', 'paid'),
(20, 55, 21, 510.0, 110.0, 400.0, '2026-11-16 09:00:00', '2026-11-30 09:00:00', 'unpaid'),
(34, 51, 26, 630.0, 130.0, 500.0, '2026-11-17 10:00:00', '2026-12-01 10:00:00', 'paid'),
(47, 69, NULL, 420.0, 70.0, 350.0, '2026-11-18 11:15:00', '2026-12-02 11:15:00', 'unpaid'),
(60, 18, 9, 930.0, 230.0, 700.0, '2026-11-19 13:30:00', '2026-12-03 13:30:00', 'partially_paid'),
(11, 49, 19, 280.0, 30.0, 250.0, '2026-11-20 08:15:00', '2026-12-04 08:15:00', 'paid'),
(23, 50, NULL, 460.0, 110.0, 350.0, '2026-11-21 09:30:00', '2026-12-05 09:30:00', 'paid'),
(36, 39, 18, 740.0, 140.0, 600.0, '2026-11-22 10:45:00', '2026-12-06 10:45:00', 'unpaid'),
(48, 34, 27, 320.0, 70.0, 250.0, '2026-11-23 11:00:00', '2026-12-07 11:00:00', 'unpaid'),
(1, 59, NULL, 850.0, 150.0, 700.0, '2026-11-24 12:00:00', '2026-12-08 12:00:00', 'paid'),
(15, 25, NULL, 390.0, 90.0, 300.0, '2026-11-25 08:00:00', '2026-12-09 08:00:00', 'paid'),
(26, 38, NULL, 560.0, 60.0, 500.0, '2026-11-26 09:15:00', '2026-12-10 09:15:00', 'partially_paid'),
(40, 20, NULL, 690.0, 190.0, 500.0, '2026-11-27 10:30:00', '2026-12-11 10:30:00', 'unpaid'),
(52, 46, NULL, 450.0, 100.0, 350.0, '2026-11-28 11:15:00', '2026-12-12 11:15:00', 'paid'),
(5, 19, 1, 990.0, 290.0, 700.0, '2026-11-29 13:00:00', '2026-12-13 13:00:00', 'cancelled'),
(16, 48, 25, 210.0, 10.0, 200.0, '2026-11-30 08:30:00', '2026-12-14 08:30:00', 'unpaid'),
(29, 56, 17, 570.0, 120.0, 450.0, '2026-12-01 09:00:00', '2026-12-15 09:00:00', 'paid'),
(43, 52, NULL, 680.0, 180.0, 500.0, '2026-12-02 10:10:00', '2026-12-16 10:10:00', 'paid'),
(54, 64, NULL, 370.0, 70.0, 300.0, '2026-12-03 11:20:00', '2026-12-17 11:20:00', 'unpaid'),
(8, 7, 23, 820.0, 220.0, 600.0, '2026-12-04 12:15:00', '2026-12-18 12:15:00', 'paid'),
(21, 43, NULL, 310.0, 60.0, 250.0, '2026-12-05 08:00:00', '2026-12-19 08:00:00', 'paid'),
(33, 27, NULL, 520.0, 120.0, 400.0, '2026-12-06 09:15:00', '2026-12-20 09:15:00', 'partially_paid'),
(45, 12, NULL, 640.0, 140.0, 500.0, '2026-12-07 10:30:00', '2026-12-21 10:30:00', 'unpaid'),
(58, 35, 15, 400.0, 50.0, 350.0, '2026-12-08 11:00:00', '2026-12-22 11:00:00', 'paid'),
(3, 11, 5, 910.0, 210.0, 700.0, '2026-12-09 13:00:00', '2026-12-23 13:00:00', 'paid'),
(14, 37, 13, 290.0, 40.0, 250.0, '2026-12-10 08:15:00', '2026-12-24 08:15:00', 'paid'),
(27, 67, NULL, 530.0, 80.0, 450.0, '2026-12-11 09:30:00', '2026-12-25 09:30:00', 'unpaid'),
(38, 33, NULL, 750.0, 150.0, 600.0, '2026-12-12 10:45:00', '2026-12-26 10:45:00', 'unpaid'),
(50, 23, 6, 380.0, 80.0, 300.0, '2026-12-13 11:00:00', '2026-12-27 11:00:00', 'paid'),
(7, 30, 11, 880.0, 180.0, 700.0, '2026-12-14 12:00:00', '2026-12-28 12:00:00', 'cancelled'),
(19, 31, 30, 260.0, 10.0, 250.0, '2026-12-15 08:00:00', '2026-12-29 08:00:00', 'unpaid'),
(31, 44, 14, 550.0, 100.0, 450.0, '2026-12-16 09:00:00', '2026-12-30 09:00:00', 'unpaid'),
(42, 28, NULL, 710.0, 160.0, 550.0, '2026-12-17 10:15:00', '2026-12-31 10:15:00', 'unpaid'),
(55, 16, NULL, 420.0, 70.0, 350.0, '2026-12-18 11:30:00', '2027-01-01 11:30:00', 'unpaid'),
(12, 3, 2, 960.0, 260.0, 700.0, '2026-12-19 13:00:00', '2027-01-02 13:00:00', 'cancelled');

INSERT INTO payments (invoice_id, amount, payment_method, transaction_reference, paid_at, status) VALUES
(12, 200.00, 'card', 'TXN-9001', '2026-10-30 08:00:00', 'completed'),
(25, 350.00, 'cash', 'TXN-9002', '2026-10-25 12:30:00', 'completed'),
(8, 450.0, 'bank_transfer', 'TXN-9003', NULL, 'pending'),
(40, 100.0, 'pix', 'TXN-9004', NULL, 'failed'),
(55, 600.00, 'insurance', 'TXN-9005', '2026-11-24 12:00:00', 'completed'),
(15, 150.00, 'card', 'TXN-9006', '2026-10-17 08:00:00', 'refunded'),
(30, 120.00, 'cash', 'TXN-9007', '2026-10-30 14:00:00', 'completed'),
(45, 600.00, 'bank_transfer', 'TXN-9008', '2026-11-14 12:30:00', 'completed'),
(60, 400.0, 'pix', 'TXN-9009', NULL, 'pending'),
(10, 320.00, 'insurance', 'TXN-9010', '2026-10-10 14:00:00', 'completed'),
(22, 200.00, 'card', 'TXN-9011', '2026-10-22 09:00:00', 'completed'),
(35, 600.0, 'cash', 'TXN-9012', NULL, 'failed'),
(50, 300.00, 'bank_transfer', 'TXN-9013', '2026-11-19 13:30:00', 'completed'),
(65, 800.0, 'pix', 'TXN-9014', NULL, 'pending'),
(5, 150.00, 'insurance', 'TXN-9015', '2026-10-27 11:00:00', 'completed'),
(18, 450.00, 'card', 'TXN-9016', '2026-11-02 08:00:00', 'refunded'),
(32, 250.00, 'cash', 'TXN-9017', '2026-11-01 09:30:00', 'completed'),
(48, 500.00, 'bank_transfer', 'TXN-9018', '2026-11-17 10:00:00', 'completed'),
(58, 350.0, 'pix', 'TXN-9019', NULL, 'pending'),
(14, 650.00, 'insurance', 'TXN-9020', '2026-10-20 13:00:00', 'completed'),
(27, 300.00, 'card', 'TXN-9021', '2026-11-02 08:00:00', 'completed'),
(42, 400.0, 'cash', 'TXN-9022', NULL, 'failed'),
(56, 300.00, 'bank_transfer', 'TXN-9023', '2026-11-25 08:00:00', 'completed'),
(68, 200.00, 'pix', 'TXN-9024', '2026-12-07 10:30:00', 'refunded'),
(9, 400.00, 'insurance', 'TXN-9025', '2026-10-25 11:50:00', 'completed'),
(21, 300.0, 'card', 'TXN-9026', NULL, 'pending'),
(36, 200.00, 'cash', 'TXN-9027', '2026-11-05 08:00:00', 'completed'),
(51, 250.00, 'bank_transfer', 'TXN-9028', '2026-11-20 08:15:00', 'completed'),
(62, 200.0, 'pix', 'TXN-9029', NULL, 'failed'),
(4, 100.00, 'insurance', 'TXN-9030', '2026-10-30 10:40:00', 'completed'),
(20, 350.00, 'card', 'TXN-9031', '2026-10-31 11:55:00', 'completed'),
(38, 250.0, 'cash', 'TXN-9032', NULL, 'pending'),
(55, 100.00, 'bank_transfer', 'TXN-9033', '2026-11-24 12:00:00', 'completed'),
(11, 200.00, 'pix', 'TXN-9034', '2026-11-03 08:00:00', 'refunded'),
(28, 400.00, 'insurance', 'TXN-9035', '2026-11-04 09:15:00', 'completed'),
(43, 200.00, 'card', 'TXN-9036', '2026-11-12 10:15:00', 'completed'),
(58, 500.0, 'cash', 'TXN-9037', NULL, 'failed'),
(67, 300.00, 'bank_transfer', 'TXN-9038', '2026-12-06 09:15:00', 'completed'),
(7, 450.0, 'pix', 'TXN-9039', NULL, 'pending'),
(24, 200.00, 'insurance', 'TXN-9040', '2026-11-09 08:30:00', 'completed'),
(36, 250.0, 'card', 'TXN-9041', '2026-11-10 09:45:00', 'refunded'),
(49, 350.00, 'cash', 'TXN-9042', '2026-11-18 11:15:00', 'refunded'),
(62, 450.00, 'bank_transfer', 'TXN-9043', '2026-12-01 09:00:00', 'completed'),
(3, 300.0, 'pix', 'TXN-9044', NULL, 'failed'),
(17, 250.00, 'insurance', 'TXN-9045', '2026-11-14 14:45:00', 'completed'),
(31, 300.0, 'card', 'TXN-9046', NULL, 'pending'),
(45, 400.0, 'cash', 'TXN-9047', '2026-11-16 09:15:00', 'refunded'),
(59, 350.00, 'bank_transfer', 'TXN-9048', '2026-11-28 11:15:00', 'completed'),
(12, 350.00, 'pix', 'TXN-9049', '2026-11-18 11:45:00', 'refunded'),
(26, 300.00, 'insurance', 'TXN-9050', '2026-11-19 13:00:00', 'completed'),
(39, 250.00, 'card', 'TXN-9051', '2026-11-20 14:10:00', 'completed'),
(53, 450.0, 'cash', 'TXN-9052', NULL, 'failed'),
(69, 350.00, 'bank_transfer', 'TXN-9053', '2026-12-08 11:00:00', 'completed'),
(6, 300.0, 'pix', 'TXN-9054', NULL, 'pending'),
(23, 600.00, 'insurance', 'TXN-9055', '2026-11-24 11:50:00', 'completed'),
(37, 250.00, 'card', 'TXN-9056', '2026-11-25 13:00:00', 'completed'),
(50, 400.00, 'cash', 'TXN-9057', '2026-11-26 14:15:00', 'refunded'),
(63, 500.00, 'bank_transfer', 'TXN-9058', '2026-12-02 10:10:00', 'completed'),
(10, 350.0, 'pix', 'TXN-9059', NULL, 'failed'),
(25, 350.00, 'insurance', 'TXN-9060', '2026-11-29 10:40:00', 'completed'),
(40, 500.00, 'card', 'TXN-9061', '2026-11-30 11:55:00', 'completed'),
(54, 300.0, 'cash', 'TXN-9062', NULL, 'pending'),
(66, 250.00, 'bank_transfer', 'TXN-9063', '2026-12-05 08:00:00', 'completed'),
(13, 300.00, 'pix', 'TXN-9064', '2026-12-03 08:00:00', 'refunded'),
(27, 150.00, 'insurance', 'TXN-9065', '2026-12-04 09:15:00', 'completed'),
(41, 250.00, 'card', 'TXN-9066', '2026-12-05 10:30:00', 'completed'),
(55, 350.0, 'cash', 'TXN-9067', NULL, 'failed'),
(70, 700.00, 'bank_transfer', 'TXN-9068', '2026-12-09 13:00:00', 'completed'),
(19, 250.0, 'pix', 'TXN-9069', NULL, 'pending'),
(31, 350.00, 'insurance', 'TXN-9070', '2026-12-09 08:30:00', 'completed'),
(44, 300.00, 'card', 'TXN-9071', '2026-12-10 09:45:00', 'completed'),
(5, 350.00, 'cash', 'TXN-9072', '2026-12-11 11:00:00', 'refunded'),
(19, 350.00, 'bank_transfer', 'TXN-9073', '2026-12-12 12:15:00', 'completed'),
(32, 250.0, 'pix', 'TXN-9074', NULL, 'failed'),
(46, 300.00, 'insurance', 'TXN-9075', '2026-12-14 14:45:00', 'completed'),
(60, 600.0, 'card', 'TXN-9076', NULL, 'pending'),
(8, 300.00, 'cash', 'TXN-9077', '2026-12-16 09:15:00', 'completed'),
(22, 200.00, 'bank_transfer', 'TXN-9078', '2026-12-17 10:30:00', 'completed'),
(35, 250.00, 'pix', 'TXN-9079', '2026-12-18 11:45:00', 'refunded'),
(48, 450.0, 'insurance', 'TXN-9080', '2026-12-19 13:00:00', 'refunded'),
(2, 350.00, 'card', 'TXN-9081', '2026-12-20 08:15:00', 'completed'),
(16, 350.0, 'cash', 'TXN-9082', NULL, 'pending'),
(29, 200.00, 'bank_transfer', 'TXN-9083', '2026-12-22 10:45:00', 'completed'),
(43, 500.0, 'pix', 'TXN-9084', NULL, 'failed'),
(57, 300.00, 'insurance', 'TXN-9085', '2026-12-24 12:00:00', 'completed'),
(71, 250.00, 'card', 'TXN-9086', '2026-12-25 08:00:00', 'completed'),
(11, 200.00, 'cash', 'TXN-9087', '2026-12-26 09:00:00', 'refunded'),
(24, 400.0, 'bank_transfer', 'TXN-9088', '2026-12-27 10:00:00', 'refunded'),
(38, 600.0, 'pix', 'TXN-9089', NULL, 'pending'),
(52, 350.00, 'insurance', 'TXN-9090', '2026-12-29 12:30:00', 'completed'),
(65, 600.00, 'card', 'TXN-9091', '2026-12-30 13:15:00', 'completed'),
(1, 250.0, 'cash', 'TXN-9092', NULL, 'failed'),
(15, 150.00, 'bank_transfer', 'TXN-9093', '2027-01-01 09:00:00', 'completed'),
(28, 500.00, 'pix', 'TXN-9094', '2027-01-02 10:10:00', 'refunded'),
(42, 350.00, 'insurance', 'TXN-9095', '2027-01-03 11:20:00', 'completed'),
(55, 700.0, 'card', 'TXN-9096', NULL, 'pending'),
(12, 400.00, 'cash', 'TXN-9097', '2027-01-05 08:00:00', 'completed'),
(26, 500.0, 'bank_transfer', 'TXN-9098', '2027-01-06 09:15:00', 'refunded'),
(40, 350.0, 'pix', 'TXN-9099', NULL, 'failed'),
(74, 300.00, 'insurance', 'TXN-9100', '2027-01-08 11:00:00', 'completed');



UPDATE departments
SET parent_id = id
WHERE id IN (1,2,3);

UPDATE departments SET parent_id = 1 WHERE id = 4;
UPDATE departments SET parent_id = 1 WHERE id = 5;

UPDATE departments SET parent_id = 2 WHERE id = 6;
UPDATE departments SET parent_id = 2 WHERE id = 7;

UPDATE departments SET parent_id = 3 WHERE id = 8;
UPDATE departments SET parent_id = 3 WHERE id = 9;


START TRANSACTION;
SET @training_today = CURDATE();

-- قسم مستقل حتى تبقى بيانات التدريب مترابطة
INSERT INTO departments
(department_name, floor_number, phone, status)
VALUES
('Training Care Unit', 3, '+905550099900', 'active');
SET @training_department = LAST_INSERT_ID();

INSERT INTO doctors
(department_id, full_name, email, phone, specialization, license_number, hire_date, consultation_fee, status)
VALUES
(@training_department, 'Dr. Training 1', 'hospital.training1@example.invalid', '+905550099901', 'General Medicine', 'TRAIN-LIC-901', DATE_ADD(@training_today, INTERVAL -365 DAY), 100.00, 'active');
SET @training_doctor1 = LAST_INSERT_ID();

INSERT INTO doctors
(department_id, full_name, email, phone, specialization, license_number, hire_date, consultation_fee, status)
VALUES
(@training_department, 'Dr. Training 2', 'hospital.training2@example.invalid', '+905550099902', 'General Medicine', 'TRAIN-LIC-902', DATE_ADD(@training_today, INTERVAL -365 DAY), 100.00, 'active');
SET @training_doctor2 = LAST_INSERT_ID();

INSERT INTO patients
(full_name, national_id, birth_date, gender, phone, email, blood_type, city, address, emergency_contact_name, emergency_contact_phone, registered_at, status)
VALUES
('Training Patient A', 'TRAIN-PATIENT-A', '1995-05-10', 'Female', '+905550098901', 'training.patienta@example.invalid', 'O+', 'Istanbul', 'Training address A', 'Training emergency contact A', '+905550098910', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -60 DAY), '08:00:00'), 'admitted');
SET @training_patientA = LAST_INSERT_ID();

INSERT INTO patients
(full_name, national_id, birth_date, gender, phone, email, blood_type, city, address, emergency_contact_name, emergency_contact_phone, registered_at, status)
VALUES
('Training Patient B', 'TRAIN-PATIENT-B', '1990-03-15', 'Male', '+905550098902', 'training.patientb@example.invalid', 'O+', 'Istanbul', 'Training address B', 'Training emergency contact B', '+905550098920', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -60 DAY), '08:00:00'), 'active');
SET @training_patientB = LAST_INSERT_ID();

INSERT INTO rooms
(department_id, room_number, room_type, floor_number, daily_price, status)
VALUES
(@training_department, 'TRAIN-R1', 'normal', 3, 100.00, 'available');
SET @training_room1 = LAST_INSERT_ID();

INSERT INTO rooms
(department_id, room_number, room_type, floor_number, daily_price, status)
VALUES
(@training_department, 'TRAIN-R2', 'normal', 3, 100.00, 'available');
SET @training_room2 = LAST_INSERT_ID();

INSERT INTO rooms
(department_id, room_number, room_type, floor_number, daily_price, status)
VALUES
(@training_department, 'TRAIN-R3', 'normal', 3, 100.00, 'occupied');
SET @training_room3 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 1
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor1, DATE_ADD(@training_today, INTERVAL -30 DAY), '09:00:00', 'Training completed visit 1', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -31 DAY), '10:00:00'));
SET @training_appointment1 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor1, @training_appointment1, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -30 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit1 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 2
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor2, DATE_ADD(@training_today, INTERVAL -25 DAY), '09:00:00', 'Training completed visit 2', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -26 DAY), '10:00:00'));
SET @training_appointment2 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor2, @training_appointment2, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -25 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit2 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 3
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor1, DATE_ADD(@training_today, INTERVAL -20 DAY), '09:00:00', 'Training completed visit 3', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -21 DAY), '10:00:00'));
SET @training_appointment3 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor1, @training_appointment3, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -20 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit3 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 4
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor2, DATE_ADD(@training_today, INTERVAL -15 DAY), '09:00:00', 'Training completed visit 4', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -16 DAY), '10:00:00'));
SET @training_appointment4 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor2, @training_appointment4, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -15 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit4 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 5
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor1, DATE_ADD(@training_today, INTERVAL -10 DAY), '09:00:00', 'Training completed visit 5', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -11 DAY), '10:00:00'));
SET @training_appointment5 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor1, @training_appointment5, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -10 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit5 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 6
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor2, DATE_ADD(@training_today, INTERVAL -5 DAY), '09:00:00', 'Training completed visit 6', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -6 DAY), '10:00:00'));
SET @training_appointment6 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientA, @training_doctor2, @training_appointment6, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -5 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL 7 DAY));
SET @training_visit6 = LAST_INSERT_ID();

-- موعد مكتمل مرتبط بالزيارة 7
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientB, @training_doctor1, DATE_ADD(@training_today, INTERVAL -13 DAY), '09:00:00', 'Training completed visit 7', 'completed', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -14 DAY), '10:00:00'));
SET @training_appointment7 = LAST_INSERT_ID();

INSERT INTO medical_visits
(patient_id, doctor_id, appointment_id, visit_date, symptoms, diagnosis, doctor_notes, follow_up_date)
VALUES
(@training_patientB, @training_doctor1, @training_appointment7, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -13 DAY), '09:00:00'), 'Training follow-up symptoms', 'Training routine follow-up', 'Synthetic record for SQL exercises.', DATE_ADD(@training_today, INTERVAL -7 DAY));
SET @training_visit7 = LAST_INSERT_ID();

-- موعد مجدول لليوم أو خلال الأيام السبعة القادمة
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor1, DATE_ADD(@training_today, INTERVAL 0 DAY), '18:00:00', 'Training scheduled appointment 1', 'scheduled', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -1 DAY), '10:00:00'));

-- موعد مجدول لليوم أو خلال الأيام السبعة القادمة
INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time, reason, status, created_at)
VALUES
(@training_patientA, @training_doctor1, DATE_ADD(@training_today, INTERVAL 3 DAY), '18:00:00', 'Training scheduled appointment 2', 'scheduled', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -1 DAY), '10:00:00'));

-- دواء يُوصف للمريض A في زيارتين مختلفتين
INSERT INTO medicines
(medicine_name, manufacturer, unit_price, stock_quantity, minimum_stock, expiry_date, status)
VALUES
('Training Medicine Repeated', 'Training Manufacturer', 5.00, 20, 5, DATE_ADD(@training_today, INTERVAL 365 DAY), 'Available');
SET @training_medicine_used = LAST_INSERT_ID();

-- دواء لم يُوصف، يصل إلى الحد الأدنى، وتنتهي صلاحيته خلال 30 يومًا
INSERT INTO medicines
(medicine_name, manufacturer, unit_price, stock_quantity, minimum_stock, expiry_date, status)
VALUES
('Training Medicine Unused', 'Training Manufacturer', 8.00, 5, 5, DATE_ADD(@training_today, INTERVAL 15 DAY), 'Available');
SET @training_medicine_unused = LAST_INSERT_ID();

INSERT INTO prescriptions
(visit_id, prescribed_at, notes)
VALUES
(@training_visit1, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -30 DAY), '09:30:00'), 'Synthetic prescription for database practice only.');
SET @training_prescription1 = LAST_INSERT_ID();

INSERT INTO prescription_items
(prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
VALUES
(@training_prescription1, @training_medicine_used, 'Training dose', 'Once daily', 7, 7);

INSERT INTO prescriptions
(visit_id, prescribed_at, notes)
VALUES
(@training_visit2, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -25 DAY), '09:30:00'), 'Synthetic prescription for database practice only.');
SET @training_prescription2 = LAST_INSERT_ID();

INSERT INTO prescription_items
(prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
VALUES
(@training_prescription2, @training_medicine_used, 'Training dose', 'Once daily', 7, 7);

-- فحص مستخدم أو فحص لم يُطلب نهائيًا
INSERT INTO lab_tests
(test_name, category, price, normal_range, status)
VALUES
('Training Lab Test Used', 'Training', 25.00, 'Training reference range', 'Active');
SET @training_lab_used = LAST_INSERT_ID();

-- فحص مستخدم أو فحص لم يُطلب نهائيًا
INSERT INTO lab_tests
(test_name, category, price, normal_range, status)
VALUES
('Training Lab Test Unused', 'Training', 25.00, 'Training reference range', 'Active');
SET @training_lab_unused = LAST_INSERT_ID();

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit1, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -30 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -30 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit2, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -25 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -25 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit3, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -20 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -20 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit4, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -15 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -15 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit5, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -10 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -10 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit6, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -5 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -5 DAY), '11:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- فحص مكتمل؛ للمريض A سبعة فحوصات، وأحدها أطول من المتوسط
INSERT INTO patient_lab_tests
(visit_id, lab_test_id, ordered_at, completed_at, result, result_status, status)
VALUES
(@training_visit6, @training_lab_used, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -5 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -5 DAY), '16:00:00'), 'Training result within reference range', 'Normal', 'completed');

-- إقامة مكتملة أو إقامة حالية في غرفة مستقلة
INSERT INTO admissions
(patient_id, room_id, doctor_id, admitted_at, discharged_at, admission_reason, status)
VALUES
(@training_patientA, @training_room1, @training_doctor1, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -21 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -19 DAY), '08:00:00'), 'Training short completed stay', 'discharged');
SET @training_admission1 = LAST_INSERT_ID();

-- إقامة مكتملة أو إقامة حالية في غرفة مستقلة
INSERT INTO admissions
(patient_id, room_id, doctor_id, admitted_at, discharged_at, admission_reason, status)
VALUES
(@training_patientB, @training_room2, @training_doctor1, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -14 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(@training_today, INTERVAL -8 DAY), '08:00:00'), 'Training longer completed stay', 'discharged');
SET @training_admission2 = LAST_INSERT_ID();

-- إقامة مكتملة أو إقامة حالية في غرفة مستقلة
INSERT INTO admissions
(patient_id, room_id, doctor_id, admitted_at, discharged_at, admission_reason, status)
VALUES
(@training_patientA, @training_room3, @training_doctor1, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -1 DAY), '08:00:00'), NULL, 'Training current admission', 'admitted');
SET @training_admission3 = LAST_INSERT_ID();

-- الفاتورة والزيارة والإقامة تخص المريض نفسه؛ المبلغ يطابق الدفعة
INSERT INTO invoices
(patient_id, visit_id, admission_id, subtotal, insurance_discount, total_amount, issued_at, due_date, payment_status)
VALUES
(@training_patientA, @training_visit3, @training_admission1, 325.00, 0.00, 325.00, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -19 DAY), '09:00:00'), DATE_ADD(@training_today, INTERVAL -5 DAY), 'paid');
SET @training_invoice1 = LAST_INSERT_ID();

INSERT INTO payments
(invoice_id, amount, payment_method, transaction_reference, paid_at, status)
VALUES
(@training_invoice1, 325.00, 'card', 'TRAIN-TXN-901', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -19 DAY), '10:00:00'), 'completed');

-- الفاتورة والزيارة والإقامة تخص المريض نفسه؛ المبلغ يطابق الدفعة
INSERT INTO invoices
(patient_id, visit_id, admission_id, subtotal, insurance_discount, total_amount, issued_at, due_date, payment_status)
VALUES
(@training_patientB, @training_visit7, @training_admission2, 700.00, 0.00, 700.00, TIMESTAMP(DATE_ADD(@training_today, INTERVAL -8 DAY), '09:00:00'), DATE_ADD(@training_today, INTERVAL 6 DAY), 'paid');
SET @training_invoice2 = LAST_INSERT_ID();

INSERT INTO payments
(invoice_id, amount, payment_method, transaction_reference, paid_at, status)
VALUES
(@training_invoice2, 700.00, 'card', 'TRAIN-TXN-902', TIMESTAMP(DATE_ADD(@training_today, INTERVAL -8 DAY), '10:00:00'), 'completed');

COMMIT;

-- ملخص السجلات الجديدة: المريض A لديه 6 زيارات و7 فحوصات.
SELECT patients.id, patients.full_name,
       COUNT(DISTINCT medical_visits.id) AS visit_count,
       COUNT(DISTINCT patient_lab_tests.id) AS test_count
FROM patients
LEFT JOIN medical_visits ON medical_visits.patient_id = patients.id
LEFT JOIN patient_lab_tests ON patient_lab_tests.visit_id = medical_visits.id
WHERE patients.id IN (@training_patientA, @training_patientB)
GROUP BY patients.id, patients.full_name;


-- من هنا تبدا تعليمات ال ( Queries ) 

-- تعليمة عرض جميع المرضى 

SELECT * FROM patients;

-- عرض جميع الأطباء مع القسم الخاص بكل طبيب

SELECT doctors.id, doctors.full_name AS doctor_name, departments.department_name AS department_name 
FROM doctors 
JOIN departments ON doctors.department_id = departments.id 
ORDER BY doctors.id ASC;

-- عرض جميع المواعيد مع اسم المريض والطبيب والقسم

SELECT 
    appointments.id AS appointment_id,
    patients.full_name AS patient_name,
    doctors.full_name AS doctor_name,
    departments.department_name AS department_name
FROM appointments
JOIN patients ON appointments.patient_id = patients.id
JOIN doctors ON appointments.doctor_id = doctors.id
JOIN departments ON doctors.department_id = departments.id
ORDER BY appointments.id ASC;

-- عرض مواعيد اليوم

SELECT * FROM appointments WHERE appointment_date = CURDATE() ORDER BY id ASC;

-- عرض المواعيد المجدولة خلال 7 أيام، بما فيها اليوم

SELECT *
FROM appointments
WHERE appointment_date >= CURDATE()
  AND appointment_date < DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND status = 'scheduled'
ORDER BY appointment_date ASC, appointment_time ASC;

-- عرض المرضى الذين لديهم أكثر من 3 مواعيد

SELECT patients.id, patients.full_name, COUNT(appointments.id) AS total_appointments 
FROM patients 
JOIN appointments ON patients.id = appointments.patient_id 
GROUP BY patients.id, patients.full_name 
HAVING COUNT(appointments.id) > 3;

-- عرض المرضى الذين لم يحجزوا أي موعد

SELECT patients.id, patients.full_name 
FROM patients 
LEFT JOIN appointments ON patients.id = appointments.patient_id 
WHERE appointments.id IS NULL;

-- عرض الأطباء الذين لا توجد لديهم مواعيد

SELECT doctors.id, doctors.full_name 
FROM doctors 
LEFT JOIN appointments ON doctors.id = appointments.doctor_id 
WHERE appointments.id IS NULL;

-- حساب عدد المواعيد لكل طبيب 

SELECT 
    doctors.id, 
    doctors.full_name, 
    COUNT(appointments.id) AS total_appointments 
FROM doctors 
LEFT JOIN appointments ON doctors.id = appointments.doctor_id 
GROUP BY doctors.id, doctors.full_name 
ORDER BY doctors.id ASC;

-- حساب عدد المواعيد لكل قسم

SELECT 
    departments.id, 
    departments.department_name, 
    COUNT(appointments.id) AS total_appointments 
FROM departments 
LEFT JOIN doctors ON departments.id = doctors.department_id 
LEFT JOIN appointments ON doctors.id = appointments.doctor_id 
GROUP BY departments.id, departments.department_name 
ORDER BY departments.id ASC;

-- عرض الطبيب صاحب أكبر عدد من المواعيد المكتملة

SELECT 
    doctors.id, 
    doctors.full_name, 
    COUNT(appointments.id) AS completed_appointments 
FROM doctors 
JOIN appointments ON doctors.id = appointments.doctor_id 
WHERE appointments.status = 'completed' 
GROUP BY doctors.id, doctors.full_name 
ORDER BY completed_appointments DESC, doctors.id ASC 
LIMIT 1;

-- عرض نسبة no_show لكل طبيب

SELECT 
    doctors.id, 
    doctors.full_name, 
    COUNT(appointments.id) AS total_appointments,
    COUNT(CASE WHEN appointments.status = 'no_show' THEN appointments.id END) AS no_show_count,
    COALESCE(ROUND(
        100.0 * COUNT(CASE WHEN appointments.status = 'no_show' THEN appointments.id END)
        / NULLIF(COUNT(appointments.id), 0), 2
    ), 0) AS no_show_percentage 
FROM doctors 
LEFT JOIN appointments ON doctors.id = appointments.doctor_id 
GROUP BY doctors.id, doctors.full_name 
ORDER BY doctors.id ASC;

-- عرض المرضى الذين لديهم أكثر من 5 زيارات طبية

SELECT 
    patients.id, 
    patients.full_name, 
    COUNT(medical_visits.id) AS total_visits 
FROM patients 
JOIN medical_visits ON patients.id = medical_visits.patient_id 
GROUP BY patients.id, patients.full_name 
HAVING COUNT(medical_visits.id) > 5 
ORDER BY patients.id ASC;

-- عرض آخر زيارة لكل مريض

SELECT
    patients.id AS patient_id,
    patients.full_name,
    medical_visits.id AS visit_id,
    medical_visits.visit_date,
    medical_visits.diagnosis
FROM patients
JOIN medical_visits ON patients.id = medical_visits.patient_id
WHERE NOT EXISTS (
    SELECT 1
    FROM medical_visits AS v2
    WHERE v2.patient_id = medical_visits.patient_id
      AND (
          v2.visit_date > medical_visits.visit_date
          OR (v2.visit_date = medical_visits.visit_date
              AND v2.id > medical_visits.id)
      )
)
ORDER BY patients.id ASC;

-- عرض أول زيارة لكل مريض

SELECT
    patients.id AS patient_id,
    patients.full_name,
    medical_visits.id AS visit_id,
    medical_visits.visit_date,
    medical_visits.diagnosis
FROM patients
JOIN medical_visits ON patients.id = medical_visits.patient_id
WHERE NOT EXISTS (
    SELECT 1
    FROM medical_visits AS v2
    WHERE v2.patient_id = medical_visits.patient_id
      AND (
          v2.visit_date < medical_visits.visit_date
          OR (v2.visit_date = medical_visits.visit_date
              AND v2.id < medical_visits.id)
      )
)
ORDER BY patients.id ASC;

-- عرض المرضى الذين زاروا أكثر من قسم مختلف

SELECT 
    patients.id, 
    patients.full_name, 
    COUNT(DISTINCT doctors.department_id) AS distinct_departments_count 
FROM patients 
JOIN medical_visits ON patients.id = medical_visits.patient_id 
JOIN doctors ON medical_visits.doctor_id = doctors.id 
GROUP BY patients.id, patients.full_name 
HAVING COUNT(DISTINCT doctors.department_id) > 1 
ORDER BY patients.id ASC;

-- عرض المرضى الذين زاروا أكثر من طبيب داخل نفس القسم

SELECT
patients.id,
patients.full_name,
doctors.department_id,
COUNT(DISTINCT medical_visits.doctor_id) AS doctors_count
FROM patients
JOIN medical_visits ON patients.id = medical_visits.patient_id
JOIN doctors ON medical_visits.doctor_id = doctors.id
GROUP BY patients.id, patients.full_name, doctors.department_id
HAVING COUNT(DISTINCT medical_visits.doctor_id) > 1
ORDER BY patients.id ASC;

-- عرض أكثر Diagnosis تكرارًا

SELECT
diagnosis,
COUNT(*) AS diagnosis_count
FROM medical_visits
GROUP BY diagnosis
ORDER BY diagnosis_count DESC, diagnosis ASC
LIMIT 1;

-- عرض عدد الحالات لكل Diagnosis

SELECT 
    diagnosis, 
    COUNT(*) AS cases_count 
FROM medical_visits 
GROUP BY diagnosis 
ORDER BY cases_count DESC;

-- عرض المرضى الذين لديهم Follow-up ولم يعودوا بعد تاريخ المتابعة

SELECT DISTINCT 
    patients.id, 
    patients.full_name, 
    medical_visits.follow_up_date 
FROM patients 
JOIN medical_visits ON patients.id = medical_visits.patient_id 
WHERE medical_visits.follow_up_date IS NOT NULL 
  AND medical_visits.follow_up_date < CURDATE() 
  AND NOT EXISTS (
      SELECT 1 
      FROM medical_visits AS v2 
      WHERE v2.patient_id = patients.id 
        AND DATE(v2.visit_date) > medical_visits.follow_up_date
        AND v2.visit_date <= NOW()
  ) 
ORDER BY patients.id ASC;

-- عرض الأدوية التي وصلت إلى minimum_stock أو أقل

SELECT 
    id, 
    medicine_name, 
    manufacturer, 
    stock_quantity, 
    minimum_stock, 
    status 
FROM medicines 
WHERE stock_quantity <= minimum_stock 
ORDER BY id ASC;

-- عرض الأدوية المنتهية الصلاحية

SELECT 
    id, 
    medicine_name, 
    manufacturer, 
    stock_quantity, 
    expiry_date, 
    status 
FROM medicines 
WHERE expiry_date < CURDATE() 
ORDER BY id ASC;

-- عرض الأدوية التي ستنتهي خلال 30 يومًا

SELECT 
    id, 
    medicine_name, 
    manufacturer, 
    stock_quantity, 
    expiry_date, 
    status 
FROM medicines 
WHERE expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY) 
ORDER BY id ASC;

-- عرض أكثر 10 أدوية تم وصفها

SELECT 
    medicines.id, 
    medicines.medicine_name, 
    medicines.manufacturer, 
    COUNT(prescription_items.id) AS prescription_times 
FROM medicines 
JOIN prescription_items ON medicines.id = prescription_items.medicine_id 
GROUP BY medicines.id, medicines.medicine_name, medicines.manufacturer 
ORDER BY prescription_times DESC, medicines.id ASC
LIMIT 10;

-- حساب إجمالي الكمية المطلوبة من كل دواء

SELECT 
    medicines.id, 
    medicines.medicine_name, 
    medicines.manufacturer, 
    COALESCE(SUM(prescription_items.quantity), 0) AS total_requested_quantity 
FROM medicines 
LEFT JOIN prescription_items ON medicines.id = prescription_items.medicine_id 
GROUP BY medicines.id, medicines.medicine_name, medicines.manufacturer 
ORDER BY total_requested_quantity DESC;

-- عرض الأدوية التي لم توصف لأي مريض

SELECT 
    medicines.id, 
    medicines.medicine_name, 
    medicines.manufacturer, 
    medicines.stock_quantity, 
    medicines.status 
FROM medicines 
LEFT JOIN prescription_items ON medicines.id = prescription_items.medicine_id 
WHERE prescription_items.medicine_id IS NULL 
ORDER BY medicines.id ASC;

-- عرض المرضى الذين أخذوا نفس الدواء أكثر من مرة في زيارات مختلفة

SELECT 
    patients.id AS patient_id, 
    patients.full_name, 
    medicines.id AS medicine_id, 
    medicines.medicine_name, 
    COUNT(DISTINCT medical_visits.id) AS distinct_visits_count 
FROM patients 
JOIN medical_visits ON patients.id = medical_visits.patient_id
JOIN prescriptions ON medical_visits.id = prescriptions.visit_id
JOIN prescription_items ON prescriptions.id = prescription_items.prescription_id
JOIN medicines ON prescription_items.medicine_id = medicines.id
GROUP BY patients.id, patients.full_name, medicines.id, medicines.medicine_name 
HAVING COUNT(DISTINCT medical_visits.id) > 1 
ORDER BY patients.id ASC;

-- عرض الفحوصات الأكثر طلبًا

SELECT 
    lab_tests.id, 
    lab_tests.test_name, 
    lab_tests.category, 
    COUNT(patient_lab_tests.id) AS request_count 
FROM lab_tests 
JOIN patient_lab_tests ON lab_tests.id = patient_lab_tests.lab_test_id 
GROUP BY lab_tests.id, lab_tests.test_name, lab_tests.category 
ORDER BY request_count DESC;

-- عرض المرضى الذين لديهم أكثر من 5 فحوصات

SELECT 
    patients.id AS patient_id, 
    patients.full_name, 
    COUNT(patient_lab_tests.id) AS total_tests_count 
FROM patients 
JOIN medical_visits ON patients.id = medical_visits.patient_id 
JOIN patient_lab_tests ON medical_visits.id = patient_lab_tests.visit_id
GROUP BY patients.id, patients.full_name 
HAVING COUNT(patient_lab_tests.id) > 5 
ORDER BY total_tests_count DESC;

-- عرض الفحوصات التي لم يتم طلبها نهائيًا

SELECT 
    lab_tests.id, 
    lab_tests.test_name, 
    lab_tests.category, 
    lab_tests.price, 
    lab_tests.status 
FROM lab_tests 
LEFT JOIN patient_lab_tests ON lab_tests.id = patient_lab_tests.lab_test_id 
WHERE patient_lab_tests.lab_test_id IS NULL 
ORDER BY lab_tests.id ASC;

-- حساب متوسط الوقت بين طلب الفحص واكتماله لكل نوع فحص، بالثواني

SELECT 
    lab_tests.id, 
    lab_tests.test_name, 
    lab_tests.category, 
    ROUND(AVG(TIMESTAMPDIFF(SECOND, patient_lab_tests.ordered_at,
                            patient_lab_tests.completed_at)), 2) AS avg_time_taken_seconds 
FROM patient_lab_tests 
JOIN lab_tests ON patient_lab_tests.lab_test_id = lab_tests.id
WHERE patient_lab_tests.status = 'completed'
  AND patient_lab_tests.completed_at IS NOT NULL 
GROUP BY lab_tests.id, lab_tests.test_name, lab_tests.category 
ORDER BY lab_tests.id ASC;

-- عرض الفحوصات التي استغرقت أكثر من متوسط تنفيذ نوع الفحص نفسه

SELECT 
    patient_lab_tests.id, 
    patient_lab_tests.visit_id, 
    lab_tests.test_name, 
    patient_lab_tests.ordered_at, 
    patient_lab_tests.completed_at, 
    TIMESTAMPDIFF(SECOND, patient_lab_tests.ordered_at,
                  patient_lab_tests.completed_at) AS time_taken_seconds 
FROM patient_lab_tests 
JOIN lab_tests ON patient_lab_tests.lab_test_id = lab_tests.id
WHERE patient_lab_tests.status = 'completed'
  AND patient_lab_tests.completed_at IS NOT NULL 
  AND TIMESTAMPDIFF(SECOND, patient_lab_tests.ordered_at, patient_lab_tests.completed_at) > (
      SELECT AVG(TIMESTAMPDIFF(SECOND, t2.ordered_at, t2.completed_at))
      FROM patient_lab_tests AS t2
      WHERE t2.lab_test_id = patient_lab_tests.lab_test_id
        AND t2.status = 'completed'
        AND t2.completed_at IS NOT NULL
  )
ORDER BY patient_lab_tests.id ASC;


SELECT 
    r.id, 
    r.department_id, 
    r.room_number, 
    r.room_type, 
    r.floor_number, 
    r.daily_price, 
    r.status 
FROM rooms r
WHERE r.status = 'available'
  AND NOT EXISTS (
      SELECT 1
      FROM admissions AS a
      WHERE a.room_id = r.id
        AND a.status = 'admitted'
        AND a.admitted_at <= NOW()
        AND (a.discharged_at IS NULL OR a.discharged_at > NOW())
  )
ORDER BY r.id ASC;

-- عرض الغرف المستخدمة حاليًا مع اسم المريض

SELECT 
    r.id AS room_id, 
    r.room_number, 
    r.room_type, 
    p.id AS patient_id, 
    p.full_name AS patient_name 
FROM rooms r
JOIN admissions a ON r.id = a.room_id
JOIN patients p ON a.patient_id = p.id
WHERE a.status = 'admitted'
  AND a.admitted_at <= NOW()
  AND (a.discharged_at IS NULL OR a.discharged_at > NOW())
ORDER BY r.id ASC;

-- عرض المرضى الموجودين داخل المستشفى حاليًا

SELECT 
    p.id AS patient_id, 
    p.full_name, 
    p.gender, 
    p.phone, 
    a.admitted_at, 
    a.room_id 
FROM patients p
JOIN admissions a ON p.id = a.patient_id 
WHERE a.status = 'admitted'
  AND a.admitted_at <= NOW()
  AND (a.discharged_at IS NULL OR a.discharged_at > NOW()) 
ORDER BY p.id ASC;

-- حساب عدد أيام الإقامة لكل Admission مكتمل

SELECT 
    id, 
    patient_id, 
    room_id, 
    admitted_at, 
    discharged_at, 
    DATEDIFF(discharged_at, admitted_at) AS stay_duration_days 
FROM admissions 
WHERE status = 'discharged'
  AND discharged_at IS NOT NULL
  AND discharged_at <= NOW() 
ORDER BY id ASC;

-- حساب متوسط مدة الإقامة في كل قسم

SELECT 
    d.id AS department_id,
    d.department_name,
    ROUND(AVG(DATEDIFF(a.discharged_at, a.admitted_at)), 0) AS avg_stay_duration_days
FROM departments d
JOIN rooms r ON d.id = r.department_id
JOIN admissions a ON r.id = a.room_id
WHERE a.status = 'discharged'
  AND a.discharged_at IS NOT NULL
  AND a.discharged_at <= NOW()
GROUP BY d.id, d.department_name
ORDER BY d.id ASC;

-- عرض المرضى الذين مدة إقامتهم المكتملة أعلى من متوسط مدة الإقامة في المستشفى

SELECT
    p.id AS patient_id,
    p.full_name AS patient_name,
    d.department_name,
    DATEDIFF(a.discharged_at, a.admitted_at) AS patient_stay_days,
    ROUND(hospital_avg.avg_stay_days, 2) AS hospital_avg_days
FROM admissions a
JOIN rooms r ON a.room_id = r.id
JOIN departments d ON r.department_id = d.id
JOIN patients p ON a.patient_id = p.id
CROSS JOIN (
    SELECT AVG(DATEDIFF(discharged_at, admitted_at)) AS avg_stay_days
    FROM admissions
    WHERE status = 'discharged'
      AND discharged_at IS NOT NULL
      AND discharged_at <= NOW()
) hospital_avg
WHERE a.status = 'discharged'
  AND a.discharged_at IS NOT NULL
  AND a.discharged_at <= NOW()
  AND DATEDIFF(a.discharged_at, a.admitted_at) > hospital_avg.avg_stay_days
ORDER BY p.id ASC;



-- عرض أكثر غرفة تم استخدامها

SELECT 
    r.id AS room_id,
    r.room_number,
    d.department_name,
    COUNT(a.id) AS total_usage_count
FROM rooms r
JOIN admissions a ON r.id = a.room_id
JOIN departments d ON r.department_id = d.id
GROUP BY r.id, r.room_number, d.department_name
ORDER BY total_usage_count DESC
LIMIT 1;




-- عرض الأقسام التي نسبة إشغال غرفها حاليًا أعلى من 80%

SELECT
    d.id AS department_id,
    d.department_name,
    COUNT(r.id) AS total_rooms,
    SUM(
        CASE WHEN EXISTS (
            SELECT 1
            FROM admissions a
            WHERE a.room_id = r.id
              AND a.status = 'admitted'
              AND a.admitted_at <= NOW()
              AND (
                  a.discharged_at IS NULL
                  OR a.discharged_at > NOW()
              )
        ) THEN 1 ELSE 0 END
    ) AS occupied_rooms,
    ROUND(
        100.0 * SUM(
            CASE WHEN EXISTS (
                SELECT 1
                FROM admissions a
                WHERE a.room_id = r.id
                  AND a.status = 'admitted'
                  AND a.admitted_at <= NOW()
                  AND (
                      a.discharged_at IS NULL
                      OR a.discharged_at > NOW()
                  )
            ) THEN 1 ELSE 0 END
        ) / COUNT(r.id),
        2
    ) AS occupancy_rate_percentage
FROM departments d
JOIN rooms r ON r.department_id = d.id
GROUP BY d.id, d.department_name
ORDER BY occupancy_rate_percentage DESC;

-- من هنا تبدا إستعلامات ( Financial Queries )

-- إجمالي قيمة الفواتير

SELECT 
    SUM(total_amount) AS grand_total_invoices
FROM invoices;

-- إجمالي المبالغ المدفوعة

SELECT 
    SUM(amount) AS total_paid_amount
FROM payments
WHERE status = 'completed';

-- إجمالي المبالغ غير المحصلة

SELECT 
    SUM(total_amount) AS total_uncollected_amount
FROM invoices
WHERE payment_status IN ('unpaid', 'partially_paid');

-- المبلغ المتبقي لكل فاتورة

SELECT 
    i.id AS invoice_id,
    i.total_amount,
    COALESCE(SUM(CASE WHEN p.status = 'completed' THEN p.amount ELSE 0 END), 0) AS total_paid,
    (i.total_amount - COALESCE(SUM(CASE WHEN p.status = 'completed' THEN p.amount ELSE 0 END), 0)) AS remaining_unpaid_amount
FROM invoices i
LEFT JOIN payments p ON i.id = p.invoice_id
GROUP BY i.id, i.total_amount
ORDER BY i.id ASC;

-- المرضى الذين لديهم فواتير غير مدفوعة

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    COUNT(i.id) AS unpaid_invoices_count
FROM patients p
JOIN invoices i ON p.id = i.patient_id
WHERE i.payment_status IN ('unpaid', 'partially_paid')
GROUP BY p.id, p.full_name
ORDER BY p.id ASC;

-- المرضى الذين مجموع ديونهم أعلى من 1000 

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    ROUND(SUM(i.total_amount) - COALESCE(SUM(CASE WHEN pay.status = 'completed' THEN pay.amount ELSE 0 END), 0), 0) AS total_debt
FROM patients p
JOIN invoices i ON p.id = i.patient_id
LEFT JOIN payments pay ON i.id = pay.invoice_id
WHERE i.payment_status != 'cancelled'
GROUP BY p.id, p.full_name
HAVING total_debt > 1000
ORDER BY p.id ASC;

-- إجمالي الإيرادات لكل شهر

SELECT 
    DATE_FORMAT(p.paid_at, '%Y-%m') AS revenue_month,
    ROUND(SUM(p.amount), 0) AS total_revenue
FROM payments p
WHERE p.status = 'completed'
GROUP BY revenue_month
ORDER BY revenue_month ASC;

-- إجمالي الإيرادات لكل قسم

SELECT 
    d.department_name,
    ROUND(SUM(p.amount), 0) AS total_revenue
FROM payments p
JOIN invoices i ON p.invoice_id = i.id
JOIN medical_visits mv ON i.visit_id = mv.id
JOIN doctors doc ON mv.doctor_id = doc.id
JOIN departments d ON doc.department_id = d.id
WHERE p.status = 'completed'
GROUP BY d.id, d.department_name
ORDER BY total_revenue DESC;

-- إجمالي الإيرادات الناتجة عن كل طبيب

SELECT 
    doc.full_name AS doctor_name,
    ROUND(SUM(p.amount), 0) AS total_revenue
FROM payments p
JOIN invoices i ON p.invoice_id = i.id
JOIN medical_visits mv ON i.visit_id = mv.id
JOIN doctors doc ON mv.doctor_id = doc.id
WHERE p.status = 'completed'
GROUP BY doc.id, doc.full_name
ORDER BY total_revenue DESC;

-- الشهر صاحب أعلى إيرادات

SELECT 
    DATE_FORMAT(p.paid_at, '%Y-%m') AS revenue_month,
    ROUND(SUM(p.amount), 0) AS total_revenue
FROM payments p
WHERE p.status = 'completed'
GROUP BY revenue_month
ORDER BY total_revenue DESC
LIMIT 1;

-- طريقة الدفع الأكثر استخدامًا

SELECT 
    payment_method,
    COUNT(*) AS usage_count
FROM payments
WHERE status = 'completed'
GROUP BY payment_method
ORDER BY usage_count DESC
LIMIT 1;

-- إجمالي الإيرادات حسب طريقة الدفع

SELECT 
    payment_method,
    ROUND(SUM(amount), 0) AS total_revenue
FROM payments
WHERE status = 'completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- الفواتير التي مجموع مدفوعاتها أكبر من قيمة الفاتورة

SELECT 
    i.id AS invoice_id,
    ROUND(i.total_amount, 0) AS invoice_amount,
    ROUND(SUM(p.amount), 0) AS total_paid_amount
FROM invoices i
JOIN payments p ON i.id = p.invoice_id
WHERE p.status = 'completed'
GROUP BY i.id, i.total_amount
HAVING SUM(p.amount) > i.total_amount
ORDER BY i.id ASC;

-- الفواتير المسجلة paid ولكن مجموع المدفوعات أقل من total_amount

SELECT 
    i.id AS invoice_id,
    i.payment_status,
    ROUND(i.total_amount, 0) AS invoice_amount,
    COALESCE(ROUND(SUM(p.amount), 0), 0) AS total_paid_amount
FROM invoices i
LEFT JOIN payments p ON i.id = p.invoice_id AND p.status = 'completed'
WHERE i.payment_status = 'paid'
GROUP BY i.id, i.payment_status, i.total_amount
HAVING COALESCE(SUM(p.amount), 0) < i.total_amount
ORDER BY i.id ASC;

-- الفواتير المسجلة unpaid رغم وجود Payment ناجح

SELECT DISTINCT
    i.id AS invoice_id,
    i.payment_status,
    ROUND(i.total_amount, 0) AS invoice_amount
FROM invoices i
JOIN payments p ON i.id = p.invoice_id
WHERE i.payment_status = 'unpaid' 
  AND p.status = 'completed';

-- المرضى الذين مجموع مدفوعاتهم أعلى من متوسط مدفوعات المرضى

WITH PatientPayments AS (
    SELECT 
        p.id AS patient_id,
        p.full_name AS patient_name,
        SUM(pay.amount) AS total_paid
    FROM patients p
    JOIN invoices i ON p.id = i.patient_id
    JOIN payments pay ON i.id = pay.invoice_id
    WHERE pay.status = 'completed'
    GROUP BY p.id, p.full_name
)
SELECT 
    patient_id,
    patient_name,
    ROUND(total_paid, 0) AS total_paid
FROM PatientPayments
WHERE total_paid > (SELECT AVG(total_paid) FROM PatientPayments)
ORDER BY total_paid DESC;

-- من هنا تبدا إستعلامات ال ( Subqueries )

-- الأطباء الذين عدد مرضاهم أعلى من متوسط عدد المرضى لكل طبيب

WITH DoctorPatients AS (
    SELECT 
        doc.id AS doctor_id,
        doc.full_name AS doctor_name,
        COUNT(DISTINCT mv.patient_id) AS patient_count
    FROM doctors doc
    JOIN medical_visits mv ON doc.id = mv.doctor_id
    GROUP BY doc.id, doc.full_name
)
SELECT 
    doctor_id,
    doctor_name,
    patient_count
FROM DoctorPatients
WHERE patient_count > (SELECT AVG(patient_count) FROM DoctorPatients)
ORDER BY patient_count DESC;

-- المرضى الذين عدد زياراتهم أعلى من متوسط الزيارات

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    COUNT(mv.id) AS visit_count
FROM patients p
JOIN medical_visits mv ON p.id = mv.patient_id
GROUP BY p.id, p.full_name
HAVING COUNT(mv.id) > (
    SELECT AVG(patient_visits)
    FROM (
        SELECT COUNT(id) AS patient_visits
        FROM medical_visits
        GROUP BY patient_id
    ) AS avg_visits
)
ORDER BY visit_count DESC;

-- الأدوية التي سعرها أعلى من متوسط أسعار الأدوية

SELECT 
    id,
    medicine_name,
    unit_price
FROM medicines
WHERE unit_price > (
    SELECT AVG(unit_price) 
    FROM medicines
)
ORDER BY unit_price DESC;

-- الأقسام التي إيراداتها أعلى من متوسط إيرادات الأقسام

SELECT 
    dept_id,
    dept_name,
    ROUND(total_revenue, 0) AS total_revenue
FROM (
    SELECT 
        d.id AS dept_id,
        d.department_name AS dept_name,
        SUM(p.amount) AS total_revenue
    FROM departments d
    JOIN doctors doc ON d.id = doc.department_id
    JOIN medical_visits mv ON doc.id = mv.doctor_id
    JOIN invoices i ON mv.id = i.visit_id
    JOIN payments p ON i.id = p.invoice_id
    WHERE p.status = 'completed'
    GROUP BY d.id, d.department_name
) AS department_revenues
WHERE total_revenue > (
    SELECT AVG(dept_total)
    FROM (
        SELECT SUM(p.amount) AS dept_total
        FROM departments d
        JOIN doctors doc ON d.id = doc.department_id
        JOIN medical_visits mv ON doc.id = mv.doctor_id
        JOIN invoices i ON mv.id = i.visit_id
        JOIN payments p ON i.id = p.invoice_id
        WHERE p.status = 'completed'
        GROUP BY d.id
    ) AS avg_calculation
)
ORDER BY total_revenue DESC;

-- المرضى الذين مدة إقامتهم أعلى من متوسط الإقامة 

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    DATEDIFF(a.discharged_at, a.admitted_at) AS stay_duration_days
FROM patients p
JOIN admissions a ON p.id = a.patient_id
WHERE DATEDIFF(a.discharged_at, a.admitted_at) > (
    SELECT AVG(DATEDIFF(discharged_at, admitted_at))
    FROM admissions
    WHERE discharged_at IS NOT NULL AND admitted_at IS NOT NULL
)
ORDER BY stay_duration_days DESC;

-- الأطباء الذين consultation_fee لديهم أعلى من متوسط القسم الخاص بهم

SELECT 
    d.id AS doctor_id,
    d.full_name AS doctor_name,
    dept.department_name,
    ROUND(d.consultation_fee, 0) AS consultation_fee
FROM doctors d
JOIN departments dept ON d.department_id = dept.id
WHERE d.consultation_fee > (
    SELECT AVG(d2.consultation_fee)
    FROM doctors d2
    WHERE d2.department_id = d.department_id
)
ORDER BY d.consultation_fee DESC;

-- من هنا تبدا إستعلامات ال ( Window Functions )

-- ترتيب الأطباء حسب عدد المواعيد باستخدام RANK()

WITH DoctorAppointments AS (
    SELECT 
        d.id AS doctor_id,
        d.full_name AS doctor_name,
        COUNT(a.id) AS appointment_count
    FROM doctors d
    LEFT JOIN appointments a ON d.id = a.doctor_id
    GROUP BY d.id, d.full_name
)
SELECT 
    doctor_id,
    doctor_name,
    appointment_count,
    RANK() OVER (ORDER BY appointment_count DESC) AS appointment_rank
FROM DoctorAppointments
ORDER BY appointment_rank ASC;

-- ترتيب الأطباء داخل كل قسم حسب عدد المرضى

WITH DoctorPatientCount AS (
    SELECT 
        dept.id AS department_id,
        dept.department_name,
        d.id AS doctor_id,
        d.full_name AS doctor_name,
        COUNT(DISTINCT a.patient_id) AS patient_count
    FROM departments dept
    JOIN doctors d ON dept.id = d.department_id
    LEFT JOIN appointments a ON d.id = a.doctor_id
    GROUP BY dept.id, dept.department_name, d.id, d.full_name
)
SELECT 
    department_name,
    doctor_name,
    patient_count,
    RANK() OVER (PARTITION BY department_id ORDER BY patient_count DESC) AS doctor_rank
FROM DoctorPatientCount
ORDER BY department_name, doctor_rank;

-- ترتيب المرضى حسب إجمالي إنفاقهم باستخدام DENSE_RANK()

WITH PatientSpending AS (
    SELECT 
        p.id AS patient_id,
        p.full_name AS patient_name,
        COALESCE(SUM(pay.amount), 0) AS total_spent
    FROM patients p
    LEFT JOIN invoices i ON p.id = i.patient_id
    LEFT JOIN payments pay ON i.id = pay.invoice_id AND pay.status = 'completed'
    GROUP BY p.id, p.full_name
)
SELECT 
    patient_id,
    patient_name,
    ROUND(total_spent, 2) AS total_spent,
    DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM PatientSpending
ORDER BY spending_rank ASC;

-- استخراج أعلى 3 أطباء من حيث الإيرادات داخل كل قسم

WITH DoctorRevenue AS (
    SELECT 
        dept.id AS department_id,
        dept.department_name,
        d.id AS doctor_id,
        d.full_name AS doctor_name,
        COALESCE(SUM(pay.amount), 0) AS total_revenue
    FROM departments dept
    JOIN doctors d ON dept.id = d.department_id
    LEFT JOIN medical_visits mv ON d.id = mv.doctor_id
    LEFT JOIN invoices i ON mv.id = i.visit_id
    LEFT JOIN payments pay ON i.id = pay.invoice_id AND pay.status = 'completed'
    GROUP BY dept.id, dept.department_name, d.id, d.full_name
),
RankedDoctors AS (
    SELECT 
        department_name,
        doctor_name,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY total_revenue DESC) AS revenue_rank
    FROM DoctorRevenue
)
SELECT 
    department_name,
    doctor_name,
    ROUND(total_revenue, 2) AS total_revenue,
    revenue_rank
FROM RankedDoctors
WHERE revenue_rank <= 3
ORDER BY department_name, revenue_rank;

-- ترتيب Admissions لكل مريض حسب التاريخ باستخدام ROW_NUMBER() 

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    a.id AS admission_id,
    a.admitted_at,
    a.discharged_at,
    a.admission_reason,
    a.status,
    ROW_NUMBER() OVER (PARTITION BY a.patient_id ORDER BY a.admitted_at ASC) AS admission_sequence
FROM admissions a
JOIN patients p ON a.patient_id = p.id
ORDER BY p.id, admission_sequence;


-- مقارنة قيمة كل فاتورة بالفاتورة السابقة لنفس المريض باستخدام LAG()

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    i.id AS invoice_id,
    i.issued_at,
    i.total_amount AS current_invoice_amount,
    LAG(i.total_amount) OVER (PARTITION BY i.patient_id ORDER BY i.issued_at ASC) AS previous_invoice_amount,
    (i.total_amount - LAG(i.total_amount) OVER (PARTITION BY i.patient_id ORDER BY i.issued_at ASC)) AS amount_difference
FROM invoices i
JOIN patients p ON i.patient_id = p.id
ORDER BY p.id, i.issued_at ASC;

-- عرض الفرق بين الزيارة الحالية والزيارة السابقة لكل مريض 

SELECT 
    p.id AS patient_id,
    p.full_name AS patient_name,
    mv.id AS current_visit_id,
    mv.visit_date AS current_visit_date,
    LAG(mv.visit_date) OVER (PARTITION BY mv.patient_id ORDER BY mv.visit_date ASC) AS previous_visit_date,
    DATEDIFF(mv.visit_date, LAG(mv.visit_date) OVER (PARTITION BY mv.patient_id ORDER BY mv.visit_date ASC)) AS days_since_last_visit,
    mv.diagnosis AS current_diagnosis
FROM medical_visits mv
JOIN patients p ON mv.patient_id = p.id
ORDER BY p.id, mv.visit_date ASC;

-- حساب الإيراد التراكمي شهريًا

WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(issued_at, '%Y-%m') AS revenue_month,
        SUM(total_amount) AS monthly_revenue
    FROM 
        invoices
    GROUP BY 
        DATE_FORMAT(issued_at, '%Y-%m')
)
SELECT 
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY revenue_month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM 
    MonthlyRevenue
ORDER BY 
    revenue_month;

-- مقارنة إيرادات كل شهر بالشهر السابق 

-- ملاحظة مهمة : في هذا الاستعلام من الطبيعي أن تظهر قيمة سالبية في العمود الاخير لأنه يقيس معدل أرتفاع الدخل و نزوله 

WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(issued_at, '%Y-%m') AS revenue_month,
        SUM(total_amount) AS monthly_revenue
    FROM 
        invoices
    GROUP BY 
        DATE_FORMAT(issued_at, '%Y-%m')
)
SELECT 
    revenue_month,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (ORDER BY revenue_month) AS previous_month_revenue,
    monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY revenue_month) AS revenue_difference,
    ROUND(
        ((monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY revenue_month)) / 
         NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY revenue_month), 0)) * 100, 2
    ) AS growth_percentage
FROM 
    MonthlyRevenue
ORDER BY 
    revenue_month;

-- حساب نسبة مساهمة كل قسم في إجمالي إيرادات المستشفى

WITH DepartmentRevenue AS (
    SELECT 
        d.department_name,
        SUM(i.total_amount) AS dept_revenue
    FROM 
        invoices i
    LEFT JOIN medical_visits mv ON i.visit_id = mv.id
    LEFT JOIN admissions a ON i.admission_id = a.id
    LEFT JOIN doctors doc_v ON mv.doctor_id = doc_v.id
    LEFT JOIN doctors doc_a ON a.doctor_id = doc_a.id
    JOIN departments d ON d.id = COALESCE(doc_v.department_id, doc_a.department_id)
    GROUP BY 
        d.id, d.department_name
)
SELECT 
    department_name,
    dept_revenue,
    SUM(dept_revenue) OVER () AS total_hospital_revenue,
    ROUND(
        (dept_revenue / NULLIF(SUM(dept_revenue) OVER (), 0)) * 100, 2
    ) AS contribution_percentage
FROM 
    DepartmentRevenue
ORDER BY 
    dept_revenue DESC;




-- هنا بدا كود ال ( Views )

-- إستعلام لأنشاء view ال ( patient_summary_view )

CREATE VIEW patient_summary_view AS
SELECT
    p.id AS patient_id,
    p.full_name,
    p.national_id,
    p.gender,
    p.phone,
    p.email,
    COALESCE(app.total_appointments, 0) AS total_appointments,
    COALESCE(mv.total_visits, 0) AS total_visits,
    COALESCE(adm.total_admissions, 0) AS total_admissions,
    COALESCE(inv.total_invoices, 0) AS total_invoices,
    COALESCE(pay.total_paid, 0) AS total_paid,
    (COALESCE(inv.total_invoices, 0) - COALESCE(pay.total_paid, 0)) AS outstanding_balance,
    mv.last_visit
FROM patients p
LEFT JOIN (
    SELECT patient_id, COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY patient_id
) app ON p.id = app.patient_id
LEFT JOIN (
    SELECT patient_id, COUNT(*) AS total_visits, MAX(visit_date) AS last_visit
    FROM medical_visits
    GROUP BY patient_id
) mv ON p.id = mv.patient_id
LEFT JOIN (
    SELECT patient_id, COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY patient_id
) adm ON p.id = adm.patient_id
LEFT JOIN (
    SELECT patient_id, SUM(total_amount) AS total_invoices
    FROM invoices
    GROUP BY patient_id
) inv ON p.id = inv.patient_id
LEFT JOIN (
    SELECT i.patient_id, SUM(p.amount) AS total_paid
    FROM payments p
    JOIN invoices i ON p.invoice_id = i.id
    WHERE p.status = 'completed'
    GROUP BY i.patient_id
) pay ON p.id = pay.patient_id;

-- كود إستعلام ال ( patient_summary_view ) لتجربتها

SELECT * FROM patient_summary_view;

-- كود إنشاء ال view ( doctor_performance_view )

CREATE OR REPLACE VIEW doctor_performance_view AS
SELECT
    d.full_name AS doctor,
    dep.department_name AS department,
    COALESCE(app_stats.total_appointments, 0) AS total_appointments,
    COALESCE(app_stats.completed_appointments, 0) AS completed_appointments,
    COALESCE(app_stats.cancelled_appointments, 0) AS cancelled_appointments,
    COALESCE(app_stats.no_show_appointments, 0) AS no_show_appointments,
    COALESCE(app_stats.unique_patients, 0) AS unique_patients,
    COALESCE(rev_stats.total_revenue, 0.00) AS total_revenue
FROM doctors d
JOIN departments dep ON d.department_id = dep.id
LEFT JOIN (
    SELECT
        doctor_id,
        COUNT(id) AS total_appointments,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_appointments,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_appointments,
        SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) AS no_show_appointments,
        COUNT(DISTINCT patient_id) AS unique_patients
    FROM appointments
    GROUP BY doctor_id
) app_stats ON d.id = app_stats.doctor_id
LEFT JOIN (
    SELECT
        mv.doctor_id,
        SUM(i.total_amount) AS total_revenue
    FROM invoices i
    JOIN medical_visits mv ON i.visit_id = mv.id
    GROUP BY mv.doctor_id
) rev_stats ON d.id = rev_stats.doctor_id;

-- كود لأستعلام view ال ( doctor_performance_view ) و تجربتها

SELECT * FROM doctor_performance_view;

-- كود إنشاء view ال ( room_status_view )

CREATE OR REPLACE VIEW room_status_view AS
SELECT
    r.id AS room_id,
    r.room_number,
    r.room_type,
    r.floor_number,
    r.daily_price,
    r.status AS room_status,
    p.full_name AS current_patient_name,
    a.admitted_at AS admission_date
FROM rooms r
LEFT JOIN admissions a ON r.id = a.room_id AND a.discharged_at IS NULL
LEFT JOIN patients p ON a.patient_id = p.id;

-- كود إستدعاء و تجربة view ال ( room_status_view )

SELECT * FROM room_status_view;






-- من هنا تبدا إستعلامات ال ( CTE )

-- حساب إجمالي ديون كل مريض ثم عرض المرضى الأعلى من المتوسط

WITH PatientDebtSummary AS (
    SELECT 
        p.id AS patient_id,
        p.full_name,
        SUM(i.total_amount - COALESCE(paid.total_paid, 0)) AS total_debt
    FROM patients p
    JOIN invoices i ON p.id = i.patient_id
    LEFT JOIN (
        SELECT invoice_id, SUM(amount) AS total_paid
        FROM payments
        WHERE status = 'completed'
        GROUP BY invoice_id
    ) paid ON i.id = paid.invoice_id
    GROUP BY p.id, p.full_name
    HAVING SUM(i.total_amount - COALESCE(paid.total_paid, 0)) > 0
),
AverageDebt AS (
    SELECT AVG(total_debt) AS avg_debt
    FROM PatientDebtSummary
)
SELECT 
    pds.patient_id,
    pds.full_name,
    pds.total_debt,
    ROUND(ad.avg_debt, 2) AS general_average_debt
FROM PatientDebtSummary pds
CROSS JOIN AverageDebt ad
WHERE pds.total_debt > ad.avg_debt;

-- تحليل أداء الأطباء

WITH DoctorAppointments AS (
    SELECT doctor_id, COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY doctor_id
),
DoctorVisits AS (
    SELECT doctor_id, COUNT(*) AS total_visits
    FROM medical_visits
    GROUP BY doctor_id
),
DoctorAdmissions AS (
    SELECT doctor_id, COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY doctor_id
),
DoctorRevenue AS (
    SELECT d_id AS doctor_id, SUM(total_amount) AS total_revenue
    FROM (
        SELECT mv.doctor_id AS d_id, i.total_amount
        FROM invoices i
        JOIN medical_visits mv ON i.visit_id = mv.id
        UNION ALL
        SELECT a.doctor_id AS d_id, i.total_amount
        FROM invoices i
        JOIN admissions a ON i.admission_id = a.id
    ) combined_invoices
    GROUP BY d_id
)
SELECT 
    doc.id AS doctor_id,
    doc.full_name AS doctor_name,
    dep.department_name,
    doc.specialization,
    COALESCE(da.total_appointments, 0) AS total_appointments,
    COALESCE(dv.total_visits, 0) AS total_visits,
    COALESCE(dadm.total_admissions, 0) AS total_admissions,
    COALESCE(drev.total_revenue, 0.00) AS total_revenue
FROM doctors doc
LEFT JOIN departments dep ON doc.department_id = dep.id
LEFT JOIN DoctorAppointments da ON doc.id = da.doctor_id
LEFT JOIN DoctorVisits dv ON doc.id = dv.doctor_id
LEFT JOIN DoctorAdmissions dadm ON doc.id = dadm.doctor_id
LEFT JOIN DoctorRevenue drev ON doc.id = drev.doctor_id;

-- حساب إيرادات الأقسام

WITH InvoiceDepartmentMapping AS (
    SELECT i.id AS invoice_id, i.total_amount, doc.department_id
    FROM invoices i
    JOIN medical_visits mv ON i.visit_id = mv.id
    JOIN doctors doc ON mv.doctor_id = doc.id
    
    UNION ALL
    
    SELECT i.id AS invoice_id, i.total_amount, doc.department_id
    FROM invoices i
    JOIN admissions a ON i.admission_id = a.id
    JOIN doctors doc ON a.doctor_id = doc.id
),
DepartmentSummary AS (
    SELECT 
        department_id,
        COUNT(invoice_id) AS total_invoices,
        SUM(total_amount) AS total_revenue
    FROM InvoiceDepartmentMapping
    GROUP BY department_id
)
SELECT 
    dep.id AS department_id,
    dep.department_name,
    COALESCE(ds.total_invoices, 0) AS total_invoices,
    COALESCE(ds.total_revenue, 0.00) AS total_revenue
FROM departments dep
LEFT JOIN DepartmentSummary ds ON dep.id = ds.department_id
ORDER BY total_revenue DESC;

-- استخراج المرضى ذوي الاستخدام المرتفع لخدمات المستشفى

WITH PatientAppointments AS (
    SELECT patient_id, COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY patient_id
),
PatientVisits AS (
    SELECT patient_id, COUNT(*) AS total_visits
    FROM medical_visits
    GROUP BY patient_id
),
PatientAdmissions AS (
    SELECT patient_id, COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY patient_id
),
PatientSpending AS (
    SELECT patient_id, SUM(total_amount) AS total_spent
    FROM invoices
    GROUP BY patient_id
)
SELECT 
    p.id AS patient_id,
    p.full_name,
    COALESCE(pa.total_appointments, 0) AS total_appointments,
    COALESCE(pv.total_visits, 0) AS total_visits,
    COALESCE(pad.total_admissions, 0) AS total_admissions,
    COALESCE(ps.total_spent, 0.00) AS total_spent,
    (COALESCE(pa.total_appointments, 0) + COALESCE(pv.total_visits, 0) + COALESCE(pad.total_admissions, 0)) AS total_hospital_interactions
FROM patients p
LEFT JOIN PatientAppointments pa ON p.id = pa.patient_id
LEFT JOIN PatientVisits pv ON p.id = pv.patient_id
LEFT JOIN PatientAdmissions pad ON p.id = pad.patient_id
LEFT JOIN PatientSpending ps ON p.id = ps.patient_id
ORDER BY total_hospital_interactions DESC, total_spent DESC;

-- استخراج الأدوية الأكثر استهلاكًا

WITH MedicineConsumption AS (
    SELECT 
        medicine_id,
        SUM(quantity) AS total_quantity_consumed,
        COUNT(prescription_id) AS total_times_prescribed
    FROM prescription_items
    GROUP BY medicine_id
)
SELECT 
    m.id AS medicine_id,
    m.medicine_name,
    m.manufacturer,
    m.unit_price,
    m.stock_quantity,
    COALESCE(mc.total_quantity_consumed, 0) AS total_quantity_consumed,
    COALESCE(mc.total_times_prescribed, 0) AS total_times_prescribed
FROM medicines m
LEFT JOIN MedicineConsumption mc ON m.id = mc.medicine_id
ORDER BY total_quantity_consumed DESC;

-- استخدم Recursive CTE في مشكلة مناسبة داخل النظام، ويجب شرح سبب استخدام Recursion

-- ملاحظة ل رين هذا الاستعلام ( DepartmentHierarchy ) صحيح تماما ولكن حتى يعمل يجب تعديل جدول ال ( departments )

-- و إضافة عليه عمود ( parent_id ) و أقسام فرعية و إدخال البيانات بشكل صحيح

WITH RECURSIVE DepartmentHierarchy AS (
    SELECT 
        id,
        department_name,
        parent_id,
        0 AS hierarchy_level,
        CAST(department_name AS CHAR(1000)) AS department_path
    FROM departments
    WHERE id = parent_id
    
    UNION ALL
    
    SELECT 
        d.id,
        d.department_name,
        d.parent_id,
        dh.hierarchy_level + 1,
        CONCAT(dh.department_path, ' -> ', d.department_name) AS department_path
    FROM departments d
    JOIN DepartmentHierarchy dh ON d.parent_id = dh.id
    WHERE d.id <> d.parent_id
)

SELECT 
    id,
    department_name,
    parent_id,
    hierarchy_level,
    department_path
FROM DepartmentHierarchy
ORDER BY department_path;

-- من هنا تبدا أكواد ال ( Stored Procedures )

-- كود إنشاء Procedures بأسم ( book_appointment )

DELIMITER //

CREATE PROCEDURE book_appointment(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_date DATE,
    IN p_appointment_time TIME,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_doctor_status VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status INTO v_doctor_status 
    FROM doctors 
    WHERE id = p_doctor_id;
    
    IF v_doctor_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب غير موجود في النظام.';
    ELSEIF v_doctor_status != 'active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب غير نشط حالياً ولا يمكن حجز موعد معه.';
    END IF;

    IF p_appointment_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن حجز موعد في تاريخ قديم أو في الماضي.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM appointments 
        WHERE doctor_id = p_doctor_id 
          AND appointment_date = p_appointment_date 
          AND appointment_time = p_appointment_time 
          AND status NOT IN ('cancelled')
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب لديه موعد محجوز مسبقاً في نفس التاريخ والوقت.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM appointments 
        WHERE patient_id = p_patient_id 
          AND appointment_date = p_appointment_date 
          AND appointment_time = p_appointment_time 
          AND status NOT IN ('cancelled')
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: المريض لديه موعد آخر محجوز في نفس التاريخ والوقت تماماً.';
    END IF;
    
    INSERT INTO appointments (
        patient_id, 
        doctor_id, 
        appointment_date, 
        appointment_time, 
        reason, 
        status, 
        created_at
    ) 
    VALUES (
        p_patient_id, 
        p_doctor_id, 
        p_appointment_date, 
        p_appointment_time, 
        p_reason, 
        'scheduled', 
        NOW()
    );

    COMMIT;

END //

DELIMITER ;

-- كود إنشاء Procedures التي إسمها ( admit_patient )

DELIMITER //

CREATE PROCEDURE admit_patient(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_room_id INT,
    IN p_admission_reason VARCHAR(255)
)
BEGIN
    DECLARE v_doctor_status VARCHAR(20);
    DECLARE v_room_status VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status INTO v_doctor_status 
    FROM doctors 
    WHERE id = p_doctor_id;
    
    IF v_doctor_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب غير موجود في النظام.';
    ELSEIF v_doctor_status != 'active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب غير نشط حالياً.';
    END IF;

    SELECT status INTO v_room_status 
    FROM rooms 
    WHERE id = p_room_id;
    
    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الغرفة غير موجودة في النظام.';
    ELSEIF v_room_status = 'maintenance' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الغرفة تحت الصيانة ولا يمكن التنويم فيها.';
    ELSEIF v_room_status != 'available' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الغرفة غير متاحة حالياً (مشغولة).';
    END IF;
   
    INSERT INTO admissions (
        patient_id, 
        room_id, 
        doctor_id, 
        admitted_at, 
        admission_reason, 
        status
    ) 
    VALUES (
        p_patient_id, 
        p_room_id, 
        p_doctor_id, 
        NOW(), 
        p_admission_reason, 
        'admitted'
    );

    COMMIT;

END //

DELIMITER ;

-- كود إنشاء Procedures التي إسمها ( discharge_patient )

DELIMITER //

CREATE PROCEDURE discharge_patient(
    IN p_admission_id INT
)
BEGIN
    DECLARE v_patient_id INT;
    DECLARE v_room_id INT;
    DECLARE v_admitted_at DATETIME;
    DECLARE v_visit_id INT;
    DECLARE v_daily_price DECIMAL(10,2);
    DECLARE v_stay_days INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_insurance_discount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_amount DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT patient_id, room_id, admitted_at 
    INTO v_patient_id, v_room_id, v_admitted_at
    FROM admissions 
    WHERE id = p_admission_id AND discharged_at IS NULL;

    IF v_patient_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: رقم التنويم غير موجود أو أن المريض تم تخريجه مسبقاً.';
    END IF;

    SELECT id INTO v_visit_id
    FROM medical_visits
    WHERE patient_id = v_patient_id
    ORDER BY id DESC
    LIMIT 1;

    SELECT daily_price INTO v_daily_price
    FROM rooms
    WHERE id = v_room_id;

    SET v_stay_days = GREATEST(1, TIMESTAMPDIFF(DAY, v_admitted_at, NOW()));
    SET v_subtotal = v_stay_days * v_daily_price;
    SET v_total_amount = v_subtotal - v_insurance_discount;

    UPDATE admissions 
    SET discharged_at = NOW(), 
        status = 'discharged'
    WHERE id = p_admission_id;

    INSERT INTO invoices (
        patient_id, 
        visit_id,
        admission_id, 
        subtotal, 
        insurance_discount, 
        total_amount, 
        issued_at, 
        due_date, 
        payment_status
    ) 
    VALUES (
        v_patient_id, 
        v_visit_id,
        p_admission_id, 
        v_subtotal, 
        v_insurance_discount, 
        v_total_amount, 
        NOW(), 
        DATE_ADD(NOW(), INTERVAL 15 DAY), 
        'unpaid'
    );

    COMMIT;

END //

DELIMITER ;

-- كود إنشاء Procedures التي إسمها ( pay_invoice )

DELIMITER //

CREATE PROCEDURE pay_invoice(
    IN p_invoice_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(50),
    IN p_transaction_reference VARCHAR(100)
)
BEGIN
    DECLARE v_invoice_exists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT 1 INTO v_invoice_exists
    FROM invoices
    WHERE id = p_invoice_id;

    IF v_invoice_exists IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: رقم الفاتورة غير موجود في النظام.';
    END IF;

    INSERT INTO payments (
        invoice_id, 
        amount, 
        payment_method, 
        transaction_reference, 
        paid_at, 
        status
    ) 
    VALUES (
        p_invoice_id, 
        p_amount, 
        p_payment_method, 
        p_transaction_reference, 
        NOW(), 
        'completed'
    );

    COMMIT;

END //

DELIMITER ;

-- من هنا تبدا أكواد ال ( Triggers )

-- كود إنشاء مشغل يقوم بمنع حجز طبيب في موعدين بنفس التاريخ والوقت

DELIMITER //

CREATE TRIGGER prevent_doctor_double_booking
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointments 
        WHERE doctor_id = NEW.doctor_id 
          AND appointment_date = NEW.appointment_date 
          AND appointment_time = NEW.appointment_time
          AND status NOT IN ('cancelled')
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الطبيب لديه موعد آخر محجوز بالفعل في نفس التاريخ والوقت تماماً.';
    END IF;
END //

DELIMITER ;

-- لتجربته إذا صحيح يجب تجربة حجز موعد بنفس الوقت لموعد قديم 

-- كود إنشاء مشغل يقوم بمنع إدخال المريض في غرفتين بنفس الوقت

DELIMITER //

CREATE TRIGGER prevent_patient_double_admission
BEFORE INSERT ON admissions
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM admissions 
        WHERE patient_id = NEW.patient_id 
          AND discharged_at IS NULL 
          AND status != 'cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: المريض لديه تنويم نشط حالياً في الغرفة ولا يمكن إدخاله في تنويم آخر حتى يتم تخريجه.';
    END IF;
END //

DELIMITER ;

-- لتجربة الكود إذا كان يعمل أدخل بيانات حجز مريضين في نفس الغرفة 

--  إنشاء مشغل يقوم بتغيير الغرفة إلى occupied عند Admission ناجح

DELIMITER //

CREATE TRIGGER update_room_status_on_admission
AFTER INSERT ON admissions
FOR EACH ROW
BEGIN
    UPDATE rooms 
    SET status = 'occupied' 
    WHERE id = NEW.room_id;
END //

DELIMITER ;

-- هذا المشغل يغير قيمة الحالة في جدول الغرف إلى محجوز إذا تم حجز غرفة لمريض جديد بطريقة صحيحة من دون ان يعترضها المشغل السابق

-- إعادة الغرفة إلى available عند Discharge

DELIMITER //

CREATE TRIGGER update_room_available_on_discharge
AFTER UPDATE ON admissions
FOR EACH ROW
BEGIN
    IF (OLD.discharged_at IS NULL AND NEW.discharged_at IS NOT NULL) 
       OR (OLD.status != 'discharged' AND NEW.status = 'discharged') THEN
        
        UPDATE rooms 
        SET status = 'available' 
        WHERE id = NEW.room_id;
        
    END IF;
END //

DELIMITER ;

-- لتجربة هذا المود يجب تعديل جدول ال ( admissions ) و تخريج مريض كان ماذال نائم بالمشفى و ستلاحظ وضع توقيت خروج و جعل الغرفة في حالة فارغة و متاحة 

-- منع Payment بقيمة صفر أو أقل

DELIMITER //

CREATE TRIGGER prevent_invalid_payment_amount
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن قبول عملية دفع بقيمة صفر أو أقل.';
    END IF;
END //

DELIMITER ;

-- الاول يحمي الجدول من القيم الخاطئة و الثاني يحدث الحالات 

DELIMITER //

CREATE TRIGGER update_invoice_status_after_payment
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE v_total_invoice_amount DECIMAL(10,2);
    DECLARE v_total_paid_amount DECIMAL(10,2);

    SELECT total_amount INTO v_total_invoice_amount
    FROM invoices
    WHERE id = NEW.invoice_id;

    SELECT COALESCE(SUM(amount), 0.00) INTO v_total_paid_amount
    FROM payments
    WHERE invoice_id = NEW.invoice_id 
      AND status = 'completed';

    IF v_total_paid_amount >= v_total_invoice_amount THEN
        UPDATE invoices 
        SET payment_status = 'paid' 
        WHERE id = NEW.invoice_id;
        
    ELSEIF v_total_paid_amount > 0 THEN
        UPDATE invoices 
        SET payment_status = 'partially_paid' 
        WHERE id = NEW.invoice_id;
        
    ELSE
        UPDATE invoices 
        SET payment_status = 'unpaid' 
        WHERE id = NEW.invoice_id;
    END IF;
END //

DELIMITER ;

-- هذا الكود يمنع إدخال دفعة مالية بقيمة ( 0 ) او ( قيمة سالبة )

-- منع stock_quantity من الوصول إلى قيمة سالبة

DELIMITER //

CREATE TRIGGER prevent_negative_stock_insert
BEFORE INSERT ON medicines
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن أن تكون كمية المخزون المضافة سالبة.';
    END IF;
END //

CREATE TRIGGER prevent_negative_stock_update
BEFORE UPDATE ON medicines
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن تحديث كمية المخزون لتصبح قيمة سالبة.';
    END IF;
END //

DELIMITER ;

-- هذا المشغل يمنع إدخال القيم السالبة 

-- منع استخدام دواء منتهي الصلاحية في Prescription جديدة

DELIMITER //

CREATE TRIGGER prevent_expired_med_prescription_insert
BEFORE INSERT ON prescription_items
FOR EACH ROW
BEGIN
    DECLARE med_expiry DATE;
    DECLARE med_status VARCHAR(50);
    
    SELECT expiry_date, status INTO med_expiry, med_status
    FROM medicines
    WHERE id = NEW.medicine_id;
    
    IF med_expiry < CURDATE() OR med_status = 'Expired' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن وصف أو إدراج دواء منتهي الصلاحية في الوصفة الطبية.';
    END IF;
END //

CREATE TRIGGER prevent_expired_med_prescription_update
BEFORE UPDATE ON prescription_items
FOR EACH ROW
BEGIN
    DECLARE med_expiry DATE;
    DECLARE med_status VARCHAR(50);
    
    SELECT expiry_date, status INTO med_expiry, med_status
    FROM medicines
    WHERE id = NEW.medicine_id;
    
    IF med_expiry < CURDATE() OR med_status = 'Expired' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن تحديث الوصفة بدواء منتهي الصلاحية.';
    END IF;
END //

DELIMITER ;

-- كود إنشاء مشغل يقوم بتحديث حالة Invoice عند تغير مجموع المدفوعات إذا كان تصميمك يعتمد على ذلك

DELIMITER //

CREATE PROCEDURE update_invoice_payment_status(IN target_invoice_id INT)
BEGIN
    DECLARE total_paid DECIMAL(10,2);
    DECLARE invoice_total DECIMAL(10,2);
    SELECT COALESCE(SUM(amount), 0) INTO total_paid
    FROM payments
    WHERE invoice_id = target_invoice_id AND status = 'completed';
    
    SELECT total_amount INTO invoice_total
    FROM invoices
    WHERE id = target_invoice_id;
    
    IF total_paid <= 0 THEN
        UPDATE invoices SET payment_status = 'unpaid' WHERE id = target_invoice_id;
    ELSEIF total_paid < invoice_total THEN
        UPDATE invoices SET payment_status = 'partially_paid' WHERE id = target_invoice_id;
    ELSE
        UPDATE invoices SET payment_status = 'paid' WHERE id = target_invoice_id;
    END IF;
END //

CREATE TRIGGER trg_payments_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    CALL update_invoice_payment_status(NEW.invoice_id);
END //

CREATE TRIGGER trg_payments_after_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    CALL update_invoice_payment_status(NEW.invoice_id);
    IF OLD.invoice_id != NEW.invoice_id THEN
        CALL update_invoice_payment_status(OLD.invoice_id);
    END IF;
END //

CREATE TRIGGER trg_payments_after_delete
AFTER DELETE ON payments
FOR EACH ROW
BEGIN
    CALL update_invoice_payment_status(OLD.invoice_id);
END //

DELIMITER ;

-- هذا الكود يعمل على التنسيق بين جدولي الفواتير و المدفوعات

-- من هنا يبدا كود ال ( Transactions )

-- كود المشغل المسؤول عن الحماية 

DELIMITER //

CREATE TRIGGER prevent_invalid_admission_guard
BEFORE INSERT ON admissions
FOR EACH ROW
BEGIN
    DECLARE v_room_status VARCHAR(20);
    DECLARE v_doctor_status VARCHAR(20);

    IF EXISTS (
        SELECT 1 FROM admissions 
        WHERE patient_id = NEW.patient_id 
          AND discharged_at IS NULL 
          AND status != 'cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: المريض لديه تنويم نشط حالياً ولا يمكن إدخاله في تنويم آخر.';
    END IF;

    SELECT status INTO v_room_status 
    FROM rooms 
    WHERE id = NEW.room_id;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: الغرفة غير موجودة في النظام.';
    ELSEIF v_room_status = 'maintenance' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: الغرفة تحت الصيانة ولا يمكن التنويم فيها.';
    ELSEIF v_room_status != 'available' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: الغرفة غير متاحة حالياً (مشغولة).';
    END IF;

    SELECT status INTO v_doctor_status 
    FROM doctors 
    WHERE id = NEW.doctor_id;

    IF v_doctor_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: الطبيب غير موجود في النظام.';
    ELSEIF v_doctor_status != 'active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ [حراسة المشغل]: الطبيب غير نشط حالياً.';
    END IF;

END //

DELIMITER ;

-- كود ال ( Procedure ) المسؤول عن الادخال و التعديل

DELIMITER //

CREATE PROCEDURE admit_patient_transaction(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_room_id INT,
    IN p_admission_reason VARCHAR(255),
    IN p_insurance_discount DECIMAL(10,2)
)
BEGIN
    DECLARE v_daily_price DECIMAL(10,2);
    DECLARE v_admission_id INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO admissions (
        patient_id,
        room_id,
        doctor_id,
        admitted_at,
        admission_reason,
        status
    ) 
    VALUES (
        p_patient_id,
        p_room_id,
        p_doctor_id,
        NOW(),
        p_admission_reason,
        'admitted'
    );

    SET v_admission_id = LAST_INSERT_ID();

    UPDATE rooms 
    SET status = 'occupied' 
    WHERE id = p_room_id;

    SELECT daily_price INTO v_daily_price
    FROM rooms
    WHERE id = p_room_id;

    SET v_subtotal = v_daily_price;
    SET v_total_amount = v_subtotal - COALESCE(p_insurance_discount, 0.00);

    INSERT INTO invoices (
        patient_id,
        admission_id,
        subtotal,
        insurance_discount,
        total_amount,
        issued_at,
        due_date,
        payment_status
    ) 
    VALUES (
        p_patient_id,
        v_admission_id,
        v_subtotal,
        COALESCE(p_insurance_discount, 0.00),
        v_total_amount,
        NOW(),
        DATE_ADD(NOW(), INTERVAL 15 DAY),
        'unpaid'
    );

    COMMIT;

END //

DELIMITER ;

-- كود ال ( Concurrency Challenge )

DELIMITER //

CREATE PROCEDURE admit_patient_safely(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_room_id INT,
    IN p_admission_reason VARCHAR(255),
    IN p_insurance_discount DECIMAL(10,2)
)
BEGIN
    DECLARE v_room_status VARCHAR(20);
    DECLARE v_daily_price DECIMAL(10,2);
    DECLARE v_admission_id INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status, daily_price INTO v_room_status, v_daily_price
    FROM rooms
    WHERE id = p_room_id
    FOR UPDATE;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: الغرفة غير موجودة في النظام.';
    ELSEIF v_room_status != 'available' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: عذراً، هذه الغرفة أصبحت مشغولة وتم حجزها من قبل موظف آخر للتو.';
    END IF;

    INSERT INTO admissions (
        patient_id,
        room_id,
        doctor_id,
        admitted_at,
        admission_reason,
        status
    ) 
    VALUES (
        p_patient_id,
        p_room_id,
        p_doctor_id,
        NOW(),
        p_admission_reason,
        'admitted'
    );

    SET v_admission_id = LAST_INSERT_ID();

    UPDATE rooms 
    SET status = 'occupied' 
    WHERE id = p_room_id;
    SET v_subtotal = v_daily_price;
    SET v_total_amount = v_subtotal - COALESCE(p_insurance_discount, 0.00);

    INSERT INTO invoices (
        patient_id,
        admission_id,
        subtotal,
        insurance_discount,
        total_amount,
        issued_at,
        due_date,
        payment_status
    ) 
    VALUES (
        p_patient_id,
        v_admission_id,
        v_subtotal,
        COALESCE(p_insurance_discount, 0.00),
        v_total_amount,
        NOW(),
        DATE_ADD(NOW(), INTERVAL 15 DAY),
        'unpaid'
    );

    COMMIT;

END //

DELIMITER ;

-- إضافة مشغل ليمنع Appointment completed بدون Medical Visit عندما تكون الزيارة مطلوبة

-- يعمل عندد الادخال 

DELIMITER //

CREATE TRIGGER check_appointment_completed_before_insert
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن إنشاء موعد جديد بحالة مكتمل (completed) مباشرة.';
    END IF;
END //

DELIMITER ;

-- يعمل عند التحديث

DELIMITER //

CREATE TRIGGER check_appointment_completed_before_update
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        IF NOT EXISTS (
            SELECT 1 FROM medical_visits 
            WHERE appointment_id = NEW.id
        ) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'خطأ: لا يمكن تحديث حالة الموعد إلى مكتمل (completed) لعدم وجود زيارة طبية (Medical Visit) مرتبطة به.';
        END IF;
    END IF;
END //

DELIMITER ;

-- patient_lab_tests completed بدون completed_at

-- يعمل عند الادخال 

DELIMITER //

CREATE TRIGGER check_lab_test_completed_before_insert
BEFORE INSERT ON patient_lab_tests
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND NEW.completed_at IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن إدخال اختبار مخبري بحالة مكتمل (completed) بدون تحديد وقت الإكمال (completed_at).';
    END IF;
END //

DELIMITER ;

-- يعمل عند التحديث

DELIMITER //

CREATE TRIGGER check_lab_test_completed_before_update
BEFORE UPDATE ON patient_lab_tests
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND NEW.completed_at IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن تحديث حالة الاختبار المخبري إلى مكتمل (completed) بدون تحديد وقت الإكمال (completed_at).';
    END IF;
END //

DELIMITER ;

-- Prescription تحتوي على Medicine غير active.

-- يعمل قبل الاضافة 

DELIMITER //

CREATE TRIGGER prevent_inactive_medicine_before_insert
BEFORE INSERT ON prescription_items
FOR EACH ROW
BEGIN
    DECLARE med_status VARCHAR(50);
    
    SELECT status INTO med_status 
    FROM medicines 
    WHERE id = NEW.medicine_id;
  
    IF med_status IS NULL OR med_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'خطأ: لا يمكن وصف دواء غير نشط أو غير متاح في الوصفة الطبية.';
    END IF;
END //

DELIMITER ;

-- يعمل قبل التحديث

DELIMITER //

CREATE TRIGGER prevent_inactive_medicine_before_update
BEFORE UPDATE ON prescription_items
FOR EACH ROW
BEGIN
    DECLARE med_status VARCHAR(50);
    
    IF OLD.medicine_id != NEW.medicine_id THEN
        SELECT status INTO med_status 
        FROM medicines 
        WHERE id = NEW.medicine_id;
        
        IF med_status IS NULL OR med_status != 'Available' THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'خطأ: لا يمكن تحديث الوصفة الطبية بدواء غير نشط أو غير متاح.';
        END IF;
    END IF;
END //

DELIMITER ;









-- ============================================================
-- Final Challenge
-- ============================================================

WITH 
patient_appointments AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_appointments,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_appointments
    FROM appointments
    GROUP BY patient_id
),

patient_visits AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_visits,
        MAX(visit_date) AS last_visit_date
    FROM medical_visits
    GROUP BY patient_id
),

patient_unique_doctors_depts AS (
    SELECT 
        v.patient_id,
        COUNT(DISTINCT v.doctor_id) AS unique_doctors,
        COUNT(DISTINCT d.department_id) AS unique_departments
    FROM medical_visits v
    JOIN doctors d 
        ON v.doctor_id = d.id
    GROUP BY v.patient_id
),

last_visit_ranked AS (
    SELECT 
        v.patient_id,
        doc.full_name AS last_doctor,
        ROW_NUMBER() OVER (
            PARTITION BY v.patient_id 
            ORDER BY v.visit_date DESC, v.id DESC
        ) AS rn
    FROM medical_visits v
    JOIN doctors doc 
        ON v.doctor_id = doc.id
),

last_visit_doctor AS (
    SELECT 
        patient_id, 
        last_doctor
    FROM last_visit_ranked
    WHERE rn = 1
),

patient_lab_tests_agg AS (
    SELECT 
        v.patient_id,
        COUNT(plt.id) AS total_lab_tests
    FROM medical_visits v
    JOIN patient_lab_tests plt 
        ON v.id = plt.visit_id
    GROUP BY v.patient_id
),

patient_prescriptions_agg AS (
    SELECT 
        v.patient_id,
        COUNT(p.id) AS total_prescriptions
    FROM medical_visits v
    JOIN prescriptions p 
        ON v.id = p.visit_id
    GROUP BY v.patient_id
),

patient_admissions_agg AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_admissions,
        SUM(
            DATEDIFF(
                COALESCE(discharged_at, NOW()), 
                admitted_at
            )
        ) AS total_days_admitted
    FROM admissions
    GROUP BY patient_id
),

current_admission_ranked AS (
    SELECT
        a.patient_id,
        a.room_id,
        ROW_NUMBER() OVER (
            PARTITION BY a.patient_id
            ORDER BY a.admitted_at DESC, a.id DESC
        ) AS rn
    FROM admissions a
    WHERE a.status != 'cancelled'
      AND (
            a.discharged_at IS NULL 
            OR a.discharged_at > NOW()
      )
),

current_admission_room AS (
    SELECT 
        car.patient_id,
        CONCAT(
            'Room: ', 
            r.room_number, 
            ' (', 
            r.room_type, 
            ')'
        ) AS current_room
    FROM current_admission_ranked car
    JOIN rooms r 
        ON car.room_id = r.id
    WHERE car.rn = 1
),

invoice_payments AS (
    SELECT 
        i.patient_id,
        COUNT(i.id) AS total_invoices,
        SUM(i.total_amount) AS total_billed,
        SUM(COALESCE(p_paid.paid_sum, 0)) AS total_paid
    FROM invoices i
    LEFT JOIN (
        SELECT 
            invoice_id, 
            SUM(amount) AS paid_sum
        FROM payments
        WHERE status = 'completed'
        GROUP BY invoice_id
    ) p_paid 
        ON i.id = p_paid.invoice_id
    GROUP BY i.patient_id
),

patient_active_insurance AS (
    SELECT 
        pi.patient_id,
        ic.company_name AS insurance_company,
        ROW_NUMBER() OVER (
            PARTITION BY pi.patient_id 
            ORDER BY pi.expiry_date DESC, pi.id DESC
        ) AS rn
    FROM patient_insurance pi
    JOIN insurance_companies ic 
        ON pi.insurance_company_id = ic.id
    WHERE pi.status = 'Active'
),

latest_insurance AS (
    SELECT 
        patient_id, 
        insurance_company
    FROM patient_active_insurance
    WHERE rn = 1
)

SELECT 
    pt.id AS patient_id,
    pt.full_name AS patient_name,
    TIMESTAMPDIFF(
        YEAR, 
        pt.birth_date, 
        CURDATE()
    ) AS age,

    COALESCE(pa.total_appointments, 0) AS total_appointments,
    COALESCE(pa.completed_appointments, 0) AS completed_appointments,

    COALESCE(pv.total_visits, 0) AS total_visits,

    COALESCE(pd.unique_doctors, 0) AS unique_doctors,
    COALESCE(pd.unique_departments, 0) AS unique_departments,

    COALESCE(plt.total_lab_tests, 0) AS total_lab_tests,
    COALESCE(pr.total_prescriptions, 0) AS total_prescriptions,

    COALESCE(adm.total_admissions, 0) AS total_admissions,
    COALESCE(adm.total_days_admitted, 0) AS total_days_admitted,

    COALESCE(inv.total_invoices, 0) AS total_invoices,
    COALESCE(inv.total_billed, 0.00) AS total_billed,
    COALESCE(inv.total_paid, 0.00) AS total_paid,

    (
        COALESCE(inv.total_billed, 0.00) 
        - COALESCE(inv.total_paid, 0.00)
    ) AS outstanding_balance,

    pv.last_visit_date,
    lvd.last_doctor,
    car.current_room,
    li.insurance_company

FROM patients pt

LEFT JOIN patient_appointments pa 
    ON pt.id = pa.patient_id

LEFT JOIN patient_visits pv 
    ON pt.id = pv.patient_id

LEFT JOIN patient_unique_doctors_depts pd 
    ON pt.id = pd.patient_id

LEFT JOIN last_visit_doctor lvd 
    ON pt.id = lvd.patient_id

LEFT JOIN patient_lab_tests_agg plt 
    ON pt.id = plt.patient_id

LEFT JOIN patient_prescriptions_agg pr 
    ON pt.id = pr.patient_id

LEFT JOIN patient_admissions_agg adm 
    ON pt.id = adm.patient_id

LEFT JOIN current_admission_room car 
    ON pt.id = car.patient_id

LEFT JOIN invoice_payments inv 
    ON pt.id = inv.patient_id

LEFT JOIN latest_insurance li 
    ON pt.id = li.patient_id;


-- ============================================================
-- Final Transaction Test
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS sp_execute_complete_hospital_workflow //

CREATE PROCEDURE sp_execute_complete_hospital_workflow(
    IN p_full_name VARCHAR(100),
    IN p_national_id VARCHAR(50),
    IN p_birth_date DATE,
    IN p_gender ENUM('Male', 'Female'),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_blood_type VARCHAR(10),
    IN p_city VARCHAR(50),
    IN p_address TEXT,
    IN p_emergency_contact_name VARCHAR(100),
    IN p_emergency_contact_phone VARCHAR(20),
    IN p_status VARCHAR(20),
    IN p_doctor_id INT,
    IN p_room_id INT,
    IN p_lab_test_id INT,
    IN p_insurance_company_id INT,
    IN p_policy_number VARCHAR(50)
)

BEGIN

    -- ========================================================
    -- Local variables
    -- ========================================================

    DECLARE v_patient_id INT;
    DECLARE v_appointment_id INT;
    DECLARE v_visit_id INT;
    DECLARE v_lab_test_row_id INT;
    DECLARE v_admission_id INT;
    DECLARE v_invoice_id INT;

    DECLARE v_room_status VARCHAR(30);
    DECLARE v_discount_percentage DECIMAL(5,2) DEFAULT 0.00;

    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 600.00;
    DECLARE v_insurance_discount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0.00;

    DECLARE v_first_payment DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_second_payment DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_remaining_balance DECIMAL(10,2) DEFAULT 0.00;

    DECLARE v_transaction_prefix VARCHAR(50);

    -- ========================================================
    -- Rollback if any SQL exception occurs
    -- ========================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- ========================================================
    -- Start transaction
    -- ========================================================

    START TRANSACTION;

    -- ========================================================
    -- Validate room
    -- ========================================================

    SELECT status
    INTO v_room_status
    FROM rooms
    WHERE id = p_room_id
    FOR UPDATE;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Room does not exist.';
    END IF;

    IF v_room_status <> 'available' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Room is not available.';
    END IF;

    -- ========================================================
    -- Validate doctor
    -- ========================================================

    IF NOT EXISTS (
        SELECT 1
        FROM doctors
        WHERE id = p_doctor_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Doctor does not exist.';
    END IF;

    -- ========================================================
    -- Validate lab test
    -- ========================================================

    IF NOT EXISTS (
        SELECT 1
        FROM lab_tests
        WHERE id = p_lab_test_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lab test does not exist.';
    END IF;

    -- ========================================================
    -- Validate insurance company if provided
    -- ========================================================

    IF p_insurance_company_id IS NOT NULL THEN

        SELECT coverage_percentage
        INTO v_discount_percentage
        FROM insurance_companies
        WHERE id = p_insurance_company_id;

        IF v_discount_percentage IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Insurance company does not exist.';
        END IF;

    END IF;

    -- ========================================================
    -- Create patient
    -- ========================================================

    INSERT INTO patients (
        full_name,
        national_id,
        birth_date,
        gender,
        phone,
        email,
        blood_type,
        city,
        address,
        emergency_contact_name,
        emergency_contact_phone,
        registered_at,
        status
    )
    VALUES (
        p_full_name,
        p_national_id,
        p_birth_date,
        p_gender,
        p_phone,
        p_email,
        p_blood_type,
        p_city,
        p_address,
        p_emergency_contact_name,
        p_emergency_contact_phone,
        NOW(),
        p_status
    );

    SET v_patient_id = LAST_INSERT_ID();

    -- ========================================================
    -- Create appointment
    -- ========================================================

    INSERT INTO appointments (
        patient_id,
        doctor_id,
        appointment_date,
        appointment_time,
        reason,
        status,
        created_at
    )
    VALUES (
        v_patient_id,
        p_doctor_id,
        CURDATE(),
        '09:00:00',
        'Routine checkup',
        'scheduled',
        NOW()
    );

    SET v_appointment_id = LAST_INSERT_ID();

    -- Complete the appointment
    UPDATE appointments
    SET status = 'completed'
    WHERE id = v_appointment_id;

    -- ========================================================
    -- Create medical visit
    -- ========================================================

    INSERT INTO medical_visits (
        patient_id,
        doctor_id,
        appointment_id,
        visit_date,
        symptoms,
        diagnosis,
        doctor_notes,
        follow_up_date
    )
    VALUES (
        v_patient_id,
        p_doctor_id,
        v_appointment_id,
        NOW(),
        'General checkup symptoms',
        'Initial clinical evaluation and diagnosis',
        'Regular checkup notes',
        DATE_ADD(NOW(), INTERVAL 1 MONTH)
    );

    SET v_visit_id = LAST_INSERT_ID();

    -- ========================================================
    -- Create laboratory test
    -- ========================================================

    INSERT INTO patient_lab_tests (
        visit_id,
        lab_test_id,
        ordered_at,
        result_status,
        status
    )
    VALUES (
        v_visit_id,
        p_lab_test_id,
        NOW(),
        'Pending',
        'ordered'
    );

    SET v_lab_test_row_id = LAST_INSERT_ID();

    -- Complete laboratory test
    UPDATE patient_lab_tests
    SET 
        status = 'completed',
        completed_at = NOW(),
        result = 'All parameters within normal limits',
        result_status = 'Normal'
    WHERE id = v_lab_test_row_id;

    -- ========================================================
    -- Create prescription
    -- ========================================================

    INSERT INTO prescriptions (
        visit_id,
        prescribed_at,
        notes
    )
    VALUES (
        v_visit_id,
        NOW(),
        'Antibiotic & Painkiller as directed'
    );

    -- ========================================================
    -- Create admission
    -- ========================================================

    INSERT INTO admissions (
        patient_id,
        room_id,
        doctor_id,
        admitted_at,
        admission_reason,
        status
    )
    VALUES (
        v_patient_id,
        p_room_id,
        p_doctor_id,
        NOW(),
        'Inpatient medical observation',
        'admitted'
    );

    SET v_admission_id = LAST_INSERT_ID();

    -- Occupy room
    UPDATE rooms
    SET status = 'occupied'
    WHERE id = p_room_id;

    -- ========================================================
    -- Discharge patient
    -- ========================================================

    UPDATE admissions
    SET 
        discharged_at = DATE_ADD(NOW(), INTERVAL 2 DAY),
        status = 'discharged'
    WHERE id = v_admission_id;

    -- Make room available again
    UPDATE rooms
    SET status = 'available'
    WHERE id = p_room_id;

    -- ========================================================
    -- Insurance
    -- ========================================================

    IF p_insurance_company_id IS NOT NULL THEN

        INSERT INTO patient_insurance (
            patient_id,
            insurance_company_id,
            policy_number,
            start_date,
            expiry_date,
            status
        )
        VALUES (
            v_patient_id,
            p_insurance_company_id,
            p_policy_number,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 1 YEAR),
            'Active'
        );

    END IF;

    -- ========================================================
    -- Invoice calculation
    -- ========================================================

    SET v_insurance_discount =
        (v_subtotal * COALESCE(v_discount_percentage, 0)) / 100;

    SET v_total_amount =
        v_subtotal - v_insurance_discount;

    -- ========================================================
    -- Create invoice
    -- ========================================================

    INSERT INTO invoices (
        patient_id,
        visit_id,
        admission_id,
        subtotal,
        insurance_discount,
        total_amount,
        issued_at,
        due_date,
        payment_status
    )
    VALUES (
        v_patient_id,
        v_visit_id,
        v_admission_id,
        v_subtotal,
        v_insurance_discount,
        v_total_amount,
        NOW(),
        DATE_ADD(NOW(), INTERVAL 15 DAY),
        'unpaid'
    );

    SET v_invoice_id = LAST_INSERT_ID();

    -- ========================================================
    -- Generate unique transaction prefix
    -- ========================================================

    SET v_transaction_prefix = CONCAT(
        'TXN-WF-',
        v_patient_id,
        '-',
        UNIX_TIMESTAMP()
    );

    -- ========================================================
    -- First payment = 40%
    -- ========================================================

    SET v_first_payment = ROUND(
        v_total_amount * 0.40,
        2
    );

    INSERT INTO payments (
        invoice_id,
        amount,
        payment_method,
        transaction_reference,
        paid_at,
        status
    )
    VALUES (
        v_invoice_id,
        v_first_payment,
        'card',
        CONCAT(v_transaction_prefix, '-01'),
        NOW(),
        'completed'
    );

    -- ========================================================
    -- Second payment = 30%
    -- ========================================================

    SET v_second_payment = ROUND(
        v_total_amount * 0.30,
        2
    );

    INSERT INTO payments (
        invoice_id,
        amount,
        payment_method,
        transaction_reference,
        paid_at,
        status
    )
    VALUES (
        v_invoice_id,
        v_second_payment,
        'cash',
        CONCAT(v_transaction_prefix, '-02'),
        NOW(),
        'completed'
    );

    -- ========================================================
    -- Update invoice to partially paid
    -- ========================================================

    UPDATE invoices
    SET payment_status = 'partially_paid'
    WHERE id = v_invoice_id;

    -- ========================================================
    -- Remaining 30%
    -- ========================================================

    SET v_remaining_balance =
        v_total_amount
        - (v_first_payment + v_second_payment);

    IF v_remaining_balance > 0 THEN

        INSERT INTO payments (
            invoice_id,
            amount,
            payment_method,
            transaction_reference,
            paid_at,
            status
        )
        VALUES (
            v_invoice_id,
            v_remaining_balance,
            'bank_transfer',
            CONCAT(v_transaction_prefix, '-03'),
            NOW(),
            'completed'
        );

    END IF;

    -- ========================================================
    -- Final invoice status
    -- ========================================================

    UPDATE invoices
    SET payment_status = 'paid'
    WHERE id = v_invoice_id;

    -- ========================================================
    -- Commit everything
    -- ========================================================

    COMMIT;

END //

DELIMITER ;



-- ================================================================================
 --                        PROJECT COMPLETED
-- ================================================================================