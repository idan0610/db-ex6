CREATE TABLE Customers (
		AccountNum SERIAL PRIMARY KEY,
        CustomerID INT NOT NULL UNIQUE,
        CustomerName VARCHAR NOT NULL,
        CustomerPassword VARCHAR NOT NULL,
        AccountStatus VARCHAR NOT NULL,
        Overdraft REAL NOT NULL
        CHECK (Overdraft <= 0 and (AccountStatus = 'open' or AccountStatus = 'close'))
);


CREATE TABLE Actions (
		ActionNum SERIAL PRIMARY KEY,
		AccountNum INT NOT NULL REFERENCES Customers,
		ActionName VARCHAR NOT NULL, 
		ActionDate DATE NOT NULL,
		Amount REAL NOT NULL
		CHECK (ActionName = 'receive' or ActionName = 'payment' or ActionName = 'saving' or ActionName = 'close')
);


CREATE TABLE AccountBalance (		
		AccountNum INT PRIMARY KEY REFERENCES Customers,	
		Balance REAL NOT NULL
);


CREATE TABLE Savings (
		SavingNum SERIAL PRIMARY KEY, 
		AccountNum INT NOT NULL REFERENCES Customers, 
		Deposit REAL NOT NULL, 
		DepositDate DATE NOT NULL, 
		NumOfYears INT NOT NULL, 
		Interest REAL NOT NULL
		CHECK (Deposit > 0 and NumOfYears > 0 and Interest >= 0 and Interest <= 1)
);


CREATE TABLE Top10Customers (
		AccountNum INT PRIMARY KEY REFERENCES Customers,	
		Balance REAL NOT NULL
);
