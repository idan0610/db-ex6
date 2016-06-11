CREATE OR REPLACE FUNCTION 
	triggerB_func()
RETURNS TRIGGER AS $$
DECLARE
	Overdraft REAL;
BEGIN
	SELECT c.overdraft INTO Overdraft FROM customers c WHERE c.accountnum = NEW.accountnum;
	IF NEW.balance < Overdraft THEN
		RAISE EXCEPTION '% cannot have balance lower then his overdraft', NEW.accountnum;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER triggerB BEFORE UPDATE ON accountbalance FOR EACH ROW EXECUTE PROCEDURE triggerB_func();