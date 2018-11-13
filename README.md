# doc-sql-database

Create an interactive HTML webpage after running a SQL Query to create a XML representation of the schema.

## Why was this built?

I needed a way to understand SQL Server Schemas for databases that I didn't have direct access to either due to its size or the location.
The SQL Script is relatively simple to run and it can be transported as a simple text file for me to then generate the schema report.


## Getting Started

* Get a copy of the SQL script [generate-table-xml.sql](src/SQL/generate-table-xml.sql)
* Open ```SQL Server Management Studio``` to run the SQL script in the Query Window.
* Change the database 
* Run the script and copy / paste the output into a text file called ```database.xml```
* Using the Batch file in the [src](/src) run the script pointing to the ```database.xml``` and where it should be created

## Example Output

### AdventureWorks database

* [XML format](https://joeplant.github.io/doc-sql-database/doc/AdventureWorks.Tables.xml)
* [Example HTML report](https://joeplant.github.io/doc-sql-database/doc/AdventureWorks/index.html)

### Prerequisites

This project has been built on Windows and includes the ```nxslt.exe``` binaries for html document creation


## Running the tests

Project has been created on SQL Server 2008 R2.  
Other SQL versions may have slightly different formats.

## Deployment

The purpose of this project is to allow a simple SQL script to be run on a SQL server database to extract the schema into an XML document.
The database schema is then visualised using 

## Built With

* [Bootstrap](https://getbootstrap.com/docs/3.3/)

## Authors

* **Joseph Plant** - *Initial work* - [JoePlant](https://github.com/JoePlant)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

