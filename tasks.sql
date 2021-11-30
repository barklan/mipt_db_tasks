/*markdown
## Task 1
*/

/*markdown
**1.**
*/

SELECT TOP(10)
    *
FROM
    distributor.singleSales
WHERE
    branchName = 'Екатеринбург' and
    dateId between '2011-05-29' and '2011-05-31'

/*markdown
**2.**
*/

SELECT TOP(10)
    fullname,
    salesRub,
    sales,
    itemId
FROM
    distributor.singleSales

/*markdown
**3.**
*/

SELECT
    min(salesRub) as min,
    max(salesRub) as max
FROM
    distributor.singleSales

/*markdown
**4.**
*/

SELECT
    fullname,
    salesRub,
    month(dateId)
FROM
    distributor.singleSales
WHERE
    sales = (
        SELECT
            MAX(sales) 
        FROM
            distributor.singleSales
        WHERE
            month(dateId) = 2
)

/*markdown
**5.**
*/

SELECT
    COUNT(DISTINCT checkId) AS checks
FROM
    distributor.sales

/*markdown
**6.**
*/

SELECT
    COUNT(DISTINCT checkId) AS checks
FROM
    distributor.sales
WHERE
    salesRub >= 10000

/*markdown
**7.**
*/

-- TODO (or not)

/*markdown
**8-11.** Отсортировать...
*/

-- ORDER BY ...

/*markdown
**12-13.** Получить информацию о транзакции с максимальной суммой платежа, ...
*/

SELECT TOP(10)
*
FROM
    distributor.singleSales 
WHERE
    region='Самарская область' and
    salesRub = (
        SELECT
            MAX(salesRub) 
        FROM
            distributor.singleSales 
        WHERE
            region='Самарская область'
    )

/*markdown
**14.** Переименовать красиво все наименования столбцов ...
*/

-- AS ...

/*markdown
**15-17.** Посчитать количество уникальных менеджеров со следующими условиями...
*/

SELECT
    COUNT(distinct salesManagerId) as num
FROM
    distributor.salesManager
-- WHERE ... 

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
**v2**
*/

WITH temp(branch, fullname, checks) as (
    SELECT
        branchName
        fullname,
        count(checkId)
    FROM
        distributor.singleSales
    WHERE
        fullname IS NOT NULL
    GROUP BY
        branchName,
        fullname
)
SELECT
    branch,
    fullname,
    checks
FROM
    temp
WHERE
    checks = (
        SELECT
            max(checks)
        FROM
            temp
        GROUP BY
            branch
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
**25.** Найти с помощью неточного поиска, следующие наименования компании
*/

SELECT
    companyName
FROM
    distributor.company
WHERE
    companyName like 'ООО "БЕ%'

/*markdown
**26.** Из задачи прошлого найти средний чек, который он оставляет в компании
*/

SELECT
    temp1.companyName,
    round(avg(temp2.salesRub), 1) as 'avg'
FROM
    distributor.company temp1
INNER JOIN
    distributor.singleSales temp2 on (temp1.companyName = temp2.companyName)
WHERE
    temp1.companyName like 'ООО "Б%'
GROUP BY
    temp1.companyName

/*markdown
**27.** Рассчитать АВС товарных позиций ( задача со звездочкой)
*/

-- The fuck?
with tmp as (
    SELECT
        categoriesAggregate.category,
        categoriesAggregate.sumprod,
        fullsum.sum_vseh,
        (categoriesAggregate.sumprod / fullsum.sum_vseh) * 100 as pp
    FROM
        (
            SELECT
                tov.category,
                sum(salesRub) as sumprod
            FROM
                distributor.sales prod
            LEFT JOIN
                distributor.item tov
                on prod.itemId = tov.itemId
            GROUP BY
                tov.category
        ) categoriesAggregate
    CROSS JOIN
        (
            SELECT
                sum(salesRub) as sum_vseh
            FROM
                distributor.sales
        ) fullsum
)
SELECT
    category,
    summ = sum(pp) OVER(
        ORDER BY
            pp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
from tmp

/*markdown
**28.**
*/

SELECT
    avg(n) as average
FROM
    (
        SELECT
            COUNT(itemId) as n,
            checkId
        FROM
            distributor.singleSales
        GROUP BY
            checkId
    ) as s

/*markdown
**29.**
*/

SELECT
    a.companyName,
    avg(n) as average
FROM
    (
        SELECT
            COUNT(itemId) as n,
            checkId,
            companyName
        FROM
            distributor.singleSales
        WHERE
            salesRub < 3000 and
            companyName IS NOT NULL
        GROUP BY
            checkId,
            companyName
    ) as a
GROUP BY
    a.companyName
ORDER BY
    a.companyName

/*markdown
**31.**
*/

SELECT
    fullname,
    COUNT(companyName) as countc
FROM
    distributor.singleSales
GROUP BY
    fullname
HAVING
    COUNT(companyName) > 50 and
    fullname IS NOT NULL

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
**33.**
*/

SELECT
    DISTINCT fullname,
    floor(sum(salesRub * sales)) as summ
FROM
    distributor.singleSales
GROUP BY
    fullname
HAVING
    fullname IS NOT NULL

/*markdown
**34.**
*/

SELECT top(10)
    s.itemId,
    dateId,
    yearId,
    monthId
FROM
    distributor.singleSales s
JOIN
    distributor.ddp a on s.itemId = a.itemId
GROUP BY
    s.itemId,
    dateId,
    yearId,
    monthId

/*markdown
**35.**
*/

SELECT
    avg(n) as average
FROM
    (
        SELECT
            COUNT(DISTINCT checkId) as n
        FROM
            distributor.singleSales
    ) as s
SELECT
    COUNT(itemId) as avgTxn
FROM
    distributor.singleSales

/*markdown
**36.**
*/

SELECT
    COUNT(DISTINCT account) as accounts
FROM
    (
        SELECT
            checkId,
            sum(sales * salesRub) as account
        FROM
            distributor.singleSales
        GROUP BY
            checkId
        HAVING
            COUNT(sales) > 2
    ) as s

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

/*markdown
**27.**
*/

with temp1(month, sales) as (
    SELECT
        month(distributor.singleSales.dateId) as month,
        count(distributor.singleSales.itemId)
    FROM
        distributor.singleSales
    INNER JOIN
        distributor.item i on singleSales.itemId = i.itemId
    WHERE
        i.exclusive = 'Да' and
        singleSales.category = 'Обои'
    GROUP BY
        year(distributor.singleSales.dateId),
        month(distributor.singleSales.dateId)
),
temp2(month, sales) as (
    SELECT
        month(distributor.singleSales.dateId),
        count(distributor.singleSales.itemId)
    FROM
        distributor.singleSales
    INNER JOIN
        distributor.item i on singleSales.itemId = i.itemId
    WHERE
        singleSales.category = 'Обои'
    GROUP BY
        year(distributor.singleSales.dateId),
        month(distributor.singleSales.dateId)
)
select
    (cast(temp1.sales as float) / cast(temp2.sales as float)) as boom
FROM
    temp1
INNER JOIN
    temp2 on temp1.month = temp2.month