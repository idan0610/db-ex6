CREATE OR REPLACE FUNCTION
	triggerD_func()
RETURNS TRIGGER AS $$
DECLARE
	current accountbalance%ROWTYPE;
	minBalance REAL;
BEGIN
	DELETE FROM top10customers;
	SELECT * INTO current FROM accountbalance a ORDER BY a.balance DESC;
	FOR row IN 1..10 LOOP
		IF current.accountnum IS NULL OR current.balance <= 0 THEN
			RETURN NULL;
		END IF;
		INSERT INTO top10customers (accountnum, balance) VALUES (current.accountnum, current.balance);
		SELECT * INTO current FROM accountbalance a WHERE a.balance <= current.balance 
		AND (SELECT count(*) FROM top10customers t WHERE t.accountnum = a.accountnum) = 0 ORDER BY a.balance DESC;
	END LOOP;
	SELECT t.balance INTO minBalance FROM top10customers t ORDER BY t.balance ASC;
	WHILE current.accountnum IS NOT NULL AND current.balance = minBalance LOOP
		INSERT INTO top10customers (accountnum, balance) VALUES (current.accountnum, current.balance);
		SELECT * INTO current FROM accountbalance a WHERE a.balance = current.balance 
		AND (SELECT count(*) FROM top10customers t WHERE t.accountnum = a.accountnum) = 0 ORDER BY a.balance DESC;		
	END LOOP;
	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER triggerD AFTER INSERT OR UPDATE OR DELETE ON accountbalance FOR EACH STATEMENT EXECUTE PROCEDURE triggerD_func();