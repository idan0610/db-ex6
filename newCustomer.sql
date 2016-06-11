CREATE OR REPLACE FUNCTION
	newCustomer(ID INTEGER, Name VARCHAR, Password VARCHAR, COverdraft REAL)
RETURNS INTEGER AS $$
DECLARE
	Customer INTEGER;
	ANum INTEGER;
	AStatus VARCHAR;
BEGIN
	SELECT c.customerid INTO Customer FROM customers c WHERE c.customerid = ID;
	IF Customer IS NULL THEN
		INSERT INTO customers (customerid, customername, customerpassword, accountstatus, overdraft) 
		VALUES(ID, Name, Password, 'open', COverdraft);
		SELECT c.accountnum INTO ANum FROM customers c WHERE c.customerid = ID;
		INSERT INTO accountbalance (accountnum, balance) VALUES (ANum, 0);
		RETURN ANum;
	ELSE
		SELECT c.accountstatus INTO AStatus FROM customers c WHERE c.customerid = Customer;
		IF AStatus = 'close' THEN
			UPDATE customers SET customername = Name, customerpassword = Password, 
			accountstatus = 'open', overdraft = COverdraft WHERE customerid = Customer;
			SELECT c.accountnum INTO ANum FROM customers c WHERE c.customerid = Customer;
			INSERT INTO accountbalance (accountnum, balance) VALUES (ANum, 0);
			RETURN ANum;
		ELSE
			RETURN -1;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;