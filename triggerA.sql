CREATE OR REPLACE FUNCTION
	triggerA_func()
RETURNS TRIGGER AS $$
BEGIN
	IF OLD.balance >= 0 THEN
		INSERT INTO actions(accountnum, actionname, actiondate, amount) 
		VALUES(OLD.accountnum, 'close', current_date, -1*OLD.balance);
		RAISE NOTICE '% %', OLD.balance, OLD.accountnum;
	ELSIF OLD.balance < 0 THEN
		RAISE EXCEPTION '% has negative balance and cannot be deleted', OLD.accountnum;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER triggerA BEFORE DELETE ON accountbalance FOR EACH ROW EXECUTE PROCEDURE triggerA_func();