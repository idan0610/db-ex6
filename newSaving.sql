CREATE OR REPLACE FUNCTION
	newSaving(ID INTEGER, SDeposit REAL, SDepositDate DATE, SNumOfYears INTEGER, SInterest REAL)
RETURNS INTEGER AS $$
DECLARE
	ANum INTEGER;
	AStatus VARCHAR;
	SNum INTEGER;
BEGIN
	SELECT c.accountnum INTO ANum FROM customers c WHERE c.customerid = ID;
	IF ANum IS NULL THEN
		RETURN -1;
	ELSE
		SELECT c.accountstatus INTO AStatus FROM customers c WHERE c.accountnum = ANum;
		IF AStatus = 'close' THEN
			RETURN -1;
		ELSE
			PERFORM doAction(ID, CAST('saving' AS VARCHAR), SDepositDate, CAST(-1*SDeposit AS REAL));
			INSERT INTO savings(accountnum, deposit, depositdate, numofyears, interest)
			VALUES(ANum, SDeposit, SDepositDate, SNumOfYears, SInterest);
			SELECT s.savingnum INTO SNum FROM savings s WHERE s.accountnum = ANum;
			RETURN SNum;
		END IF;
		
	END IF;
END;
$$ LANGUAGE PLPGSQL;