import java.sql.*;

/**
 * @author Idan Refaeli
 */
public class CheckMySavings {
	private static Connection conn;
	
	/**
	 * Constructor for CheckMySavings, do nothing.
	 */
	public CheckMySavings()
	{
	}
	
	/**
	 * Initiate the driver for postgres and connecting to the DB.
	 * @param username
	 * @throws ClassNotFoundException 
	 * @throws SQLException 
	 */
	public void init(String username)
	{
		try {
			Class.forName("org.postgresql.Driver");
			conn = DriverManager.getConnection("jdbc:postgresql://dbcourse/public?user=" + username);
		} catch (SQLException e) {
			System.err.println("Error connecting to the DB!");
		} catch (ClassNotFoundException e) {
			System.err.println("Error connecting to the driver!");
		}
	}
	
	/**
	 * Close the connection to the DB,
	 * @throws SQLException 
	 */
	public void close()
	{
		try {
			conn.close();
		} catch (SQLException e) {
			System.err.println("Error closing the connection to the DB!");
		}
	}
	
	/**
	 * Calculate the sum of saving plan if the saving plan is complete. 
	 * @param deposit
	 * @param numOfYears
	 * @param interest
	 * @return
	 */
	private double calculateCompletePlan(double deposit, int numOfYears, double interest)
	{
		if (numOfYears == 1) {
			return deposit * (1 + interest);
		}
		else {
			return (deposit + calculateCompletePlan(deposit, numOfYears - 1, interest)) * (1 + interest);
		}
	}
	
	/**
	 * Sum all the saving plans of the given AccountNum according the given openDate.
	 * @param AccountNum
	 * @param openDate
	 * @return
	 * @throws SQLException 
	 */
	@SuppressWarnings("deprecation")
	public double checkMySavings(int AccountNum, Date openDate)
	{
		try {
			double savingsSum = 0;

			String customerQuery = "SELECT CustomerID, AccountStatus FROM customers WHERE AccountNum = ?";
			PreparedStatement customerStatement = conn.prepareStatement(customerQuery);
			customerStatement.setInt(1, AccountNum);
			ResultSet customerResult = customerStatement.executeQuery();
			boolean error = false;
			
			if (!customerResult.next())
			{
				System.err.println("Error: No customer with the given Account Number exists!");
				error = true;
			}
			else {
				String status = customerResult.getString("AccountStatus");
				if (status.equals("close"))
				{
					System.err.println("Error: The given account is closed!");
					error = true;
				}
			}
			
			customerResult.close();
			customerStatement.close();
			if (error) {
				return -1;
			}
			
			String savingsQuery = "SELECT * FROM savings WHERE AccountNum = ?";
			PreparedStatement savingsStatement = conn.prepareStatement(savingsQuery);
			savingsStatement.setInt(1, AccountNum);
			ResultSet savingsResult = savingsStatement.executeQuery();
			
			Date depositDate;
			double deposit;
			double interest;
			int numOfYears;
			
			while (savingsResult.next()) {
				depositDate = savingsResult.getDate("DepositDate");
				numOfYears = savingsResult.getInt("NumOfYears");
				deposit = savingsResult.getDouble("Deposit");
				interest = savingsResult.getDouble("Interest");
				if (openDate.getYear() >= depositDate.getYear() + 1900)
				{
					if (depositDate.getYear() + 1900 + numOfYears > openDate.getYear()) {
						savingsSum += deposit * (openDate.getYear() - depositDate.getYear() - 1900);
					}
					else {
						savingsSum += calculateCompletePlan(deposit, numOfYears, interest);
					}
				}
			}
			
			savingsResult.close();
			savingsStatement.close();
			return savingsSum;
		} catch (SQLException e) {
			System.err.println("Error querying the savings table in the DB!");
			return -1;
		}
	}
}
