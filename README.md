# SQL_Data_Cleaning
This project showcases a full data cleaning process using SQL, from initial data ingestion to final cleanup. The dataset contains global layoff information, including columns such as year, company, percentage_laid_off, country, and others.

The process began with importing the dataset from a CSV file into a MySQL database. Interestingly, I encountered a challenge where not all rows could be directly imported. After several attempts, I discovered a helpful online tool (https://www.convertcsv.com/csv-to-sql.htm) that converted the entire CSV file into SQL INSERT statements, which allowed me to successfully populate the database with all records.

Once the data was fully loaded, I performed a thorough cleaning process. This included:

Identifying and removing duplicates
Handling missing values appropriately
Verifying data consistency and normalization
This project reflects not only technical SQL skills but also problem-solving and adaptability when facing common data engineering obstacles. It serves as a solid example of practical data preparation in a real-world scenario.
