# doc-sql-database

Create an interactive HTML webpage showing a Database schema.
The purpose of the separate SQL script will mean that sometimes the SQL server is not local and you need something simple to dump the schema.

A SQL script is provided that will create a xml document showing the tables, columns, and relationships for the current database. 
The xml document can be transformed using XSLT into a static HTML page.

## Getting Started

Get a copy of the SQL script [generate-table-xml.sql](src/SQL/generate-table-xml.sql)
Running this in SQL Server Management Studio will provide row by row xml document that can be easily copy/pasted into a text document.
The XSLT scripts can be used to convert the XML into a static web page showing the table structure.

## Example Output

### AdventureWorks database

* [XML format](doc/AdventureWorks.Tables.xml)
* [Example HTML report](doc/AdventureWorks/index.html)

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

* Inspiration
