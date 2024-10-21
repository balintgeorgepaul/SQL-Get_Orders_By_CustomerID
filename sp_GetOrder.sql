
--exec sp_GetOrder @CustomerID = 1, @StartDate = '2024-10-20', @EndDate = '2024-10-22';

alter procedure sp_GetOrder @CustomerID INT, @StartDate DATETIME, @EndDate DATETIME

as
begin
    
    begin try
       
        begin transaction;

		DECLARE 
			@OrderID INT, 
			@Total DECIMAL(10, 2),
			@ErrorMessage nvarchar(max), 
			@ErrorSeverity int,
			@ErrorState int, 
			@ErrorProcedure nvarchar(255), 
			@ErrorLine int;

		-- create a cte to calculate total orders by client
        with OrderTotals as (
            select 
                 o.OrderID
                ,o.CustomerID
                ,sum(OI.Quantity * OI.Price) as TotalOrderAmount
            from orders O
            inner join OrderItems OI on o.OrderID = OI.OrderID
            where o.CustomerID = @CustomerID
              and o.OrderDate between @StartDate and @EndDate
            group by o.OrderID, o.CustomerID
        )

		-- use windows function to give a unique nr to each order
        select 
            row_number() over (order by TotalOrderAmount desc) as RowNum
            ,OrderID
            ,TotalOrderAmount
        into #TempOrderTotals
        from OrderTotals;

		-- declare cursor to iterate through each order and execute additional operation

        declare order_cursor cursor for
        select OrderID, TotalOrderAmount
        from #TempOrderTotals;

        open order_cursor;

        fetch next from order_cursor into @OrderID, @Total;

        while @@fetch_status = 0
        begin
 
            print 'Process order ' + cast(@OrderID as varchar(10)) + ' with the amount of ' + cast(@Total as varchar(10));

            fetch next from order_cursor into @OrderID, @Total;
        end;

        -- close cursor
        close order_cursor;
        deallocate order_cursor;


        commit transaction;
    end try
    begin catch

        -- in case of any error, it rolls back the transaction and gets the error message
        rollback transaction;
    
    select 
        @ErrorMessage = error_message(), 
        @ErrorLine = error_line();

    insert into error_log ([Error_Message], [Procedure], [Error_Line], Error_Date)
    values (@ErrorMessage, 'sp_GetOrder', @ErrorLine, getdate());

end catch;
end;





