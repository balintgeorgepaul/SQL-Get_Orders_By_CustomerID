create table Orders (
    OrderID int primary key identity(1,1),
    CustomerID int,
    OrderDate datetime,
    TotalAmount decimal(10, 2)
);

insert into Orders (CustomerID, OrderDate, TotalAmount)
values 
    (1, '2024-10-20', 150.00),
    (2, '2024-10-21', 200.50),
    (1, '2024-10-22', 320.00),
    (3, '2024-10-21', 450.75);


create table OrderItems (
	OrderItemID int primary key identity(1,1),
	OrderID int FOREIGN KEY REFERENCES Orders(OrderID),
	ProductID int,
	Quantity int,
	Price decimal(10, 2)
);

insert into OrderItems (OrderID, ProductID, Quantity, Price)
values
    (1, 101, 2, 75.00),
    (2, 102, 1, 200.50),
    (3, 101, 3, 320.00),
    (4, 103, 2, 225.37);

create table error_log
(
    Error_Log_ID int identity(1,1) primary key,  
    [Error_Message] nvarchar(max),              
    [Procedure] nvarchar(255),             
    [Error_Line] int,                             
    Error_Date datetime default GETDATE()       
);

/*

drop table OrderItems
drop table Orders
drop table error_log 

*/

