Kevin Farrell
December 1st, 2020
IT FDN 130 A
Assignment 07



#FUNCTIONS

##Introduction
A function is a set of SQL statements that perform a specific task. A function accepts inputs in the form of parameters and returns a value. 
This paper describes SQL User Defined Functions (UDF’s), which are functions that require code to define them.  Since a user has to define them through code, they are different from the built-in functions. 

##When to use a SQL UDF
There are two types of SQL UDFs: table-valued and scalar-valued.  
Use table-valued UDFs when one or more values from different tables are joined and some type of calculation needs to be done to return an aggregation. A scalar-valued UDF accepts parameters and, ultimately, returns a single, atomic value.

##Differences between Scalar, Inline, and Multi-Statement Functions
**Scalar functions** are user defined functions.  You create them to perform math on integers and return the result as one unit of data.  Scalar basically means one unit of data, which is where the Scalar function gets its name.  Examples of the output would be a single integer value or a simple string of text.
An **inline table-valued function** is similar to a view.  An inline function contains a single select statement, and the columns in the select statement define the columns of the returned table set of the function. Inline table-valued functions might be more efficient than multi-statement functions, but if you can accomplish the same effort with a view, then the view would be better.
A **multi-statement table-valued function** is a function which returns a table of data, but only after some additional processing. 

##Conclusion
UDFs are functions that have been defined by the user to perform a specific task.  
