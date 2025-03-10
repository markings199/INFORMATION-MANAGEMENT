
CREATE DATABASE BankingSystem;
USE BankingSystem;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(15),
    Address TEXT
);

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    AccountType ENUM('Savings', 'Checking', 'Business'),
    Balance DECIMAL(10,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    AccountID INT,
    TransactionType ENUM('Deposit', 'Withdrawal', 'Transfer'),
    Amount DECIMAL(10,2),
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID) ON DELETE CASCADE
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    LoanAmount DECIMAL(12,2),
    InterestRate DECIMAL(5,2),
    LoanTerm INT COMMENT 'Loan duration in months',
    Status ENUM('Active', 'Paid', 'Defaulted'),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    LoanID INT,
    AmountPaid DECIMAL(10,2),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID) ON DELETE CASCADE
);

INSERT INTO Customers (FullName, Email, PhoneNumber, Address)
SELECT 
    CONCAT('Customer_', FLOOR(RAND() * 10000)),
    CONCAT('user', FLOOR(RAND() * 1000000), '@bank.com'),
    CONCAT('+639', FLOOR(RAND() * 1000000000)),
    CONCAT('Street_', FLOOR(RAND() * 10000), ', City_', FLOOR(RAND() * 100))
FROM 
   information_schema.tables
LIMIT 10000;

SELECT * FROM customers;

INSERT INTO Accounts (CustomerID, AccountType, Balance)
SELECT
    CustomerID,
    IF(RAND() > 0.5, 'Savings', 'Checking'),
    ROUND(RAND() * 100000, 2)
FROM Customers;

SELECT * FROM accounts;

INSERT INTO Transactions (AccountID, TransactionType, Amount)
SELECT
    AccountID,
    IF(RAND() > 0.5, 'Deposit', 'Withdrawal'),
    ROUND(RAND() * 5000, 2)
FROM Accounts;

SELECT * FROM transactions;

INSERT INTO Loans (CustomerID, LoanAmount, InterestRate, LoanTerm, Status)
SELECT
    CustomerID,
    ROUND(RAND() * 100000, 2),
    ROUND(RAND() * 10, 2),
    FLOOR(RAND() * 60) + 12,
    IF(RAND() > 0.5, 'Active', 'Paid')
FROM Customers;

SELECT * FROM loans;

INSERT INTO Payments (LoanID, AmountPaid)
SELECT
    LoanID,
    ROUND(RAND() * 5000, 2)
FROM Loans;

SELECT * FROM payments;

SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Accounts;
SELECT COUNT(*) FROM Transactions;
SELECT COUNT(*) FROM Loans;
SELECT COUNT(*) FROM Payments;

START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountID = 1;
UPDATE Accounts SET Balance = Balance + 1000 WHERE AccountID = 2;
INSERT INTO Transactions (AccountID, TransactionType, Amount)
VALUES (1, 'Transfer', 1000), (2, 'Transfer', 1000);
COMMIT;

SELECT * FROM transactions;

START TRANSACTION;
UPDATE Loans SET Status = 'Paid' WHERE LoanID = 5;
INSERT INTO Payments (LoanID, AmountPaid) VALUES (5, 5000);
COMMIT;

SELECT * FROM payments;

CREATE USER 'bank_clerk'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT, UPDATE ON BankingSystem.Accounts TO 'bank_clerk'@'localhost';

CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'readonlypass';
GRANT SELECT ON BankingSystem.* TO 'auditor'@'localhost';

SHOW GRANTS FOR 'bank_clerk'@'localhost';
SHOW GRANTS FOR 'auditor'@'localhost';

ALTER TABLE Accounts ADD AccountHolder VARCHAR(255) NOT NULL;

SELECT * FROM Accounts WHERE AccountHolder = '' OR 1=1;

PREPARE stmt FROM 'SELECT * FROM Accounts WHERE AccountHolder = ?';
SET @holder = 'Alice Johnson';
EXECUTE stmt USING @holder;
DEALLOCATE PREPARE stmt;

INSERT INTO Accounts (CustomerID, AccountType, Balance, CreatedAt, AccountHolder)
VALUES (1, 'Savings', 5000.00, NOW(), 'Alice Johnson');

UPDATE Accounts 
SET AccountHolder = 'Alice Johnson' 
WHERE AccountID = 1;  -- Change 1 to an existing AccountID

SELECT * FROM Accounts WHERE AccountHolder = 'Alice Johnson';

START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID BETWEEN 1 AND 2000;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID BETWEEN 2001 AND 4000;
SAVEPOINT bulk_transaction;

SELECT * FROM Accounts WHERE AccountID BETWEEN 1 AND 5;

COMMIT;

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 500 WHERE AccountID = 3;
UPDATE Accounts SET Balance = Balance + 500 WHERE AccountID = 4;
COMMIT;

SELECT @@TRANSACTION_ISOLATION;