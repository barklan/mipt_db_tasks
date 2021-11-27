/*markdown
## Task 1
*/

/*markdown
**18.** Сколько в среднем обслуживает клиентов менеджер филиала.
*/

SELECT
    region,
    COUNT(DISTINCT checkId) / COUNT(DISTINCT fullname)
FROM
    distributor.singleSales 
WHERE
    fullname IS NOT NULL
GROUP BY
    region

/*markdown
**19.** Сколько всего клиентов обслужил филиал за определенный период.
*/

SELECT
    COUNT(sales.checkId),
    branch.branchName
FROM
    distributor.sales
INNER JOIN
    distributor.branch on (sales.branchId = branch.branchId)
GROUP BY
    sales.branchId, branch.branchName

/*markdown
**20**. Какой менеджер обслужил в филиале, максимальное кол-во клиентов
*/

WITH temp(managerId, checksSold) as (
    SELECT
        salesManagerId, count(sales.checkId)
    FROM
        distributor.sales
    WHERE
        salesManagerId IS NOT NULL
    GROUP BY
        salesManagerId
)
SELECT
    managerId,
    surname,
    [names],
    checksSold
FROM
    temp
INNER JOIN
    distributor.salesManager on (salesManager.salesManagerId = temp.managerId)
WHERE
    checksSold = (
        SELECT
            max(checksSold)
        FROM
            temp
    )

/*markdown
**21**. Какой менеджер, принес максимальную выручку в филиале за определенный месяц
*/

SELECT TOP(10)
    max(salesRub) as maxSalesRub,
    salesManagerId
FROM
    distributor.sales 
WHERE
    branchId = 4 AND
    month(dateId) = 8
GROUP BY
    salesManagerId

/*markdown
**22**. Рассчитать средний чек клиенту по выбранному менеджеру
*/

SELECT TOP(10)
    avg(salesRub),
    salesManager.surname
FROM
    distributor.sales
INNER JOIN
    distributor.salesManager on (salesManager.salesManagerId = sales.salesManagerId)
GROUP BY
    sales.salesManagerId, salesManager.surname

/*markdown
**23**. Рассчитать средний чек клиента по филиалу
*/

SELECT
    avg(salesRub), branchName
FROM
    distributor.sales
INNER JOIN
    distributor.branch on (branch.branchId = sales.branchId)
GROUP BY
    branch.branchId, branchName

/*markdown
**24**. Средний чек клиента по менеджерам внутри филиалов
*/

-- TODO

/*markdown
**32.** 
*/

WITH sms(managerId, numberOfBranches) AS (
    SELECT
        sm.salesManagerId,
        COUNT(DISTINCT branch.branchId)
    FROM
        distributor.sales
    INNER JOIN
        distributor.branch on (sales.branchId = branch.branchId)
    INNER JOIN
        distributor.salesManager as sm on (sales.salesManagerId = sm.salesManagerId)
    GROUP BY
        sm.salesManagerId
    HAVING COUNT(DISTINCT branch.branchId) > 1
)

SELECT TOP(10)
    managerId,
    numberOfBranches,
    salesManager.surname,
    salesManager.[names]
FROM
    sms
INNER JOIN
    distributor.salesManager on (sms.managerId = salesManager.salesManagerId)

/*markdown
# Task 2
*/

/*markdown
**1.** Рассчитать выручку компании в разрезе: Год – Месяц – Выручка компании. Представленные данные отсортировать: Год, Месяц
*/

SELECT TOP(10)
    SUM(distributor.singleSales.salesRub)
FROM
    distributor.singleSales
group by
    distributor.singleSales.companyName, 
    YEAR(distributor.singleSales.dateId),
    MONTH(distributor.singleSales.dateId)