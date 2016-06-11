CREATE OR REPLACE FUNCTION
	closeCustomer(ID INTEGER)
RETURNS INTEGER AS $$
DECLARE
	ANum INTEGER;
	AStatus VARCHAR;
	ABalance REAL;
BEGIN
	SELECT c.accountnum INTO ANum FROM customers c WHERE c.customerid = ID;
	IF ANum IS NULL THEN
		RETURN -1;
	ELSE
		SELECT c.accountstatus INTO AStatus FROM customers c WHERE c.accountnum = ANum;
		IF AStatus = 'close' THEN
			RETURN -1;
		ELSE
			SELECT a.balance INTO ABalance FROM accountbalance a WHERE a.accountnum = ANum;
			DELETE FROM accountbalance a WHERE a.accountnum = ANum;
			DELETE FROM savings s WHERE s.accountnum = ANum;
			DELETE FROM top10customers t WHERE t.accountnum = ANum;
			UPDATE customers SET accountstatus = 'close' WHERE accountnum = ANum;
			RETURN ANum;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;