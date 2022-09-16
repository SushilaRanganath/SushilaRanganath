--1.a)Display a list of all property names and their property id’s for Owner Id: 1426.

SELECT  p.Name AS PropertyName, op.PropertyId  FROM  dbo.Property p, dbo.OwnerProperty op
WHERE  p.Id =op.Id 
AND  op.OwnerId=1426;

---1 b)Display the current home value for each property in question a). 


select A.id, B.propertyid, B.ownerid, c.value from dbo.property A
left join dbo.[OwnerProperty] B
on A.id=b.propertyid
left join dbo.propertyhomevalue C
on A.id=c.propertyid
and c.IsActive=1
where B.ownerid=1426;

--1.c)1 c)i. For each property in question a), return the following:                                                                      
--Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query that returns the sum of all payments from start date to end date. 


SELECT tp.PropertyId, 
CASE 
 WHEN PaymentFrequencyId = 1 THEN (DATEDIFF(Week,tP.StartDate,tp.EndDate)*PaymentAmount)
 WHEN PaymentFrequencyId = 2 THEN (DATEDIFF(Week,tp.StartDate ,tp.EndDate)*PaymentAmount /2)
 WHEN PaymentFrequencyId = 3 THEN (DATEDIFF(Week,tp.StartDate ,tp.EndDate)*12*PaymentAmount /52)
END AS SumOfAllPayments
FROM TenantProperty tp 
WHERE tp.PropertyId IN('5597', '5637', '5638');

--1 c)ii. Display the yield.


SELECT Yield FROM PropertyFinance 
WHERE PropertyId IN('5597', '5637', '5638');



--1d)Display all the jobs available

WITH TempTable
AS (
    SELECT TP.PropertyId, (CASE
                 WHEN [PaymentFrequencyId] = '1' THEN (DATEDIFF(Week,TP.[StartDate],TP.[EndDate])*[PaymentAmount])
                 WHEN [PaymentFrequencyId] = '2' THEN (DATEDIFF(Week,TP.[StartDate],TP.[EndDate])*[PaymentAmount]/2)
                 WHEN [PaymentFrequencyId] = '3' THEN (DATEDIFF(Week,TP.[StartDate],TP.[EndDate])*12*[PaymentAmount]/52)
                END) as TRP, COALESCE(PE.Amount,0) as Amount, PF.[CurrentHomeValue]
        FROM [dbo].[TenantProperty] as TP
        LEFT JOIN [dbo].[PropertyExpense] as PE ON TP.PropertyId = PE.PropertyId
        LEFT JOIN [dbo].[PropertyFinance] as PF ON TP.PropertyId = PF.PropertyId
    )

SELECT [PropertyId], (TRP-[Amount])/[CurrentHomeValue]*100 as Yield
FROM TempTable
WHERE PropertyId IN ('5597', '5637', '5638');

--1e)Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for the properties in question a).


SELECT P.Name as PropertyName, CONCAT(FirstName,' ',LastName)as CurrentTenantName,tp.paymentAmount AS RentalPayments,tpf.Name as PaymentFrequency
FROM OwnerProperty op 
INNER JOIN TenantProperty tp ON op.PropertyId =tp.PropertyId  
INNER JOIN TenantPaymentFrequencies tpf ON tpf.Id = tp.PaymentFrequencyId 
INNER JOIN Property p ON op.Id = p.Id 
INNER JOIN Person per ON op.Id= per.Id
WHERE op.PropertyId IN('5597', '5637', '5638') AND op.OwnerId=1426;


--2.) Query For Report

 SELECT FirstName AS OwnerName,
  CONCAT(Street, ' ' ,Suburb, ' ' ,City, ' ' ,PostCode) AS Address,
  CONCAT(Bedroom,'  Bedroom , ',Bathroom,'  Bathroom') AS PropertyDetails,
  pe.Amount,pe.Description as Expense,Format(pe.Date,'dd MMM yyyy') AS Date,
  CASE
 WHEN PaymentFrequencyId = 1 THEN CONCAT('$',CAST(PaymentAmount AS int),'Per Week')
 WHEN PaymentFrequencyId = 2 THEN CONCAT('$',CAST(PaymentAmount/2 AS int),'Per Week')
 WHEN PaymentFrequencyId = 3 THEN CONCAT('$',CAST(PaymentAmount/4 AS int),'Per Week')
 END  AS RentalPayment
FROM Property p
 INNER JOIN OwnerProperty op 
    ON p.Id =op.PropertyId
  INNER JOIN Person per
    ON op.OwnerId= per.Id
  INNER JOIN Address Address
    ON p.AddressId  =Address.AddressId
  INNER JOIN TenantProperty tp
  ON p.Id = tp.PropertyId
    INNER JOIN TenantPaymentFrequencies tpf
    ON tp.paymentFrequencyId=tpf.Id 
    INNER JOIN PropertyExpense pe ON p.Id=pe.PropertyId 
WHERE OwnerId=1480;