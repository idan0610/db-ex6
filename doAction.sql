CREATE OR REPLACE FUNCTION
	doAction(ID INTEGER, AcName VARCHAR, AcDate DATE, AcAmount REAL)
RETURNS INTEGER AS $$
DECLARE
	ANum INTEGER;
	AStatus VARCHAR;
	AcNum INTEGER;
BEGIN
	SELECT c.accountnum INTO ANum FROM customers c WHERE c.customerid = ID;
	IF ANum IS NULL THEN
		RETURN -1;
	ELSE
		SELECT c.accountstatus INTO AStatus FROM customers c WHERE c.accountnum = ANum;
		IF AStatus = 'close' THEN
			RETURN -1;
		ELSE
			INSERT INTO actions(accountnum, actionname, actiondate, amount)
			VALUES(ANum, AcName, AcDate, AcAmount);
			UPDATE accountbalance SET balance = balance + AcAmount WHERE accountnum = ANum;
			SELECT a.actionnum INTO AcNum FROM actions a WHERE a.accountnum = ANum;
			RETURN AcNum;
		END IF;
	END IF;
END;
$$ LANGUAGE PLPGSQL;