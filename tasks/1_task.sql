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
**7.** Отсортировать данные по убыванию продаж в транзакциях, со следующими условиями.

a. Филиал = Москва за период с 01.06.2011 по 30.06.2011

b. Известно имя менеджера

c. Известно название компании
*/
SELECT *
FROM
    [distributor].[singleSales]
WHERE
    branchName = 'Москва' AND dateId BETWEEN '2011-06-01'
    AND '2011-06-30' AND fullname IS NOT NULL AND companyName IS NOT NULL
ORDER BY
    salesRub DESC

/*markdown
**8-11.** 8. Отсортировать данные по убыванию продаж в чеках, со следующими условиями
a. Филиал = Москва за период с 01.06.2011 по 30.06.2011
b. Известно название компании
c. Категория = Сантехника


  9. Отсортировать по возрастанию по менеджерам, внутри следующего запроса
a. Известно имя менеджера
b. Известно имя компании
c. Период с 01.02.2011 по 01.08.2011
d. Бренд Roca


  10. Отсортировать по возрастанию менеджеров и по убыванию продаж транзакций внутри менеджеров, по следующим условиями
a. Период с 01.02.2011 по 30.09.2011
b. Категория содержит слово обои
c. Известно имя менеджера
d. Количество продаж от 5 до 10


  11. Получить информацию о транзакции с максимальной суммой платежа, по следующим условиям
a. Филиал = Самара
b. Известно имя менеджера
c. Известно название компании
*/

SELECT *
FROM
    [distributor].[singleSales]
WHERE
    branchName = 'Москва' AND dateId BETWEEN '2011-06-01' AND '2011-06-30' AND companyName
    IS NOT NULL AND category = 'Сантехника'
ORDER BY
    sales DESC


SELECT *
FROM [distributor].[singleSales]
WHERE
    dateId BETWEEN '2011-02-01' AND '2011-08-01'
    AND companyName IS NOT NULL AND fullname IS NOT NULL AND brand = 'Roca'
ORDER BY
    fullname

SELECT *
FROM
    [distributor].[singleSales]
WHERE
    dateId BETWEEN '2011-02-01' AND '2011-09-30'
    AND fullname IS NOT NULL AND category LIKE '%Обои%' AND sales BETWEEN 5 AND 10
ORDER BY
    fullname ASC, salesRub DES


SELECT TOP(1) *
FROM
    [distributor].[singleSales]
WHERE
    branchName = 'Самара' AND fullname IS NOT NULL AND companyName IS NOT NULL
ORDER BY
    salesRub DESC
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
**13.** Переименовать красиво все наименования столбцов при вызове таблицы со следующими условиями
a. Количество продаж от 5
b. Известно имя менеджера
c. Категория напольные покрытия
d. Бренд Praktik
*/


SELECT [checkId] AS [Номер чека], [itemId] AS [Инд. номер товара], [branchName] AS [Город], [region] AS [Регион], sizeBranch AS [Размер склада], fullname AS [Менеджер], companyName AS [Компания], itemName AS [Наименование товара], brand AS [Брэнд], category AS [Категория], dateId AS [Дата], sales AS [Количество продаж], salesRub AS [Сумма продаж]
FROM [distributor].[singleSales]
WHERE category = 'Напольные покрытия' AND sales > 5 AND fullname IS NOT NULL AND brand = 'Praktik'


/*markdown
**14.** Посчитать количество уникальных менеджеров со следующими условиями
a. Филиал = Новосибирск
b. В фамилии присутствует сочетание букв «ов» или «ва»
c. Количество продаж от 5 до 10
*/


SELECT COUNT(DISTINCT fullname) AS [quantity]
FROM [distributor].[singleSales]
WHERE fullname LIKE '%ва%' OR fullname LIKE '%ов%' AND sales BETWEEN 5 AND 10 AND branchName = 'Новосибирск'

-- Или по таблице менеджеров (при условии окончания фамилии на -ов, -ва):

SELECT COUNT(DISTINCT surname) [quantity]
FROM [distributor].[salesManager]
WHERE surname LIKE '%ва' OR surname LIKE '%ов']


/*markdown
**15.** Посчитать кол-во уникальных клиентов со следующими условиями
a. Регион = Самарская область
b. Даты покупок с 01.09.2011
c. Покупок больше 10
d. Название компании начинается с “ООО”
*/

SELECT COUNT(DISTINCT companyName) AS [quantity]
FROM [distributor].[singleSales]
WHERE sales > 10 AND companyName LIKE 'ООО%' AND region = 'Самарская область' AND dateId > '2011-09-01'


/*markdown
**16.** Сколько обслуживает клиентов каждый менеджер со следующими условиями
a. Филиал = Москва
b. Продаж больше 10
c. Известно имя менеджера
d. Известно название компании
Отсортированы по убыванию
*/

SELECT fullname, COUNT(DISTINCT companyName) AS [Количество_клиентов]
FROM [distributor].[singleSales]
WHERE sales > 10 AND branchName = 'Москва' AND fullname IS NOT NULL AND companyName IS NOT NULL
GROUP BY fullname
ORDER BY Количество_клиентов DESC

/*markdown
**17.** Сколько в среднем обслуживает клиентов менеджер филиала
*/
SELECT branchName, COUNT(DISTINCT companyName)/COUNT(DISTINCT fullname) AS [Среднее_количество_клиентов_на менеджера_филиала]
FROM [distributor].[singleSales]
WHERE fullname IS NOT NULL
GROUP BY branchName

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
    a.fullname,
    avg(n) as average
FROM
    (
        SELECT
            COUNT(itemId) as n,
            checkId,
            fullname
        FROM
            distributor.singleSales
        WHERE
            salesRub < 3000 and
            fullname IS NOT NULL
        GROUP BY
            checkId,
            fullname
    ) as a
GROUP BY
    a.fullname
ORDER BY
    a.fullname


/*markdown
**30.**
 */

SELECT
    fullname,
    SUM(salesRub) as salesR
FROM
    distributor.singleSales
GROUP BY
    fullname
HAVING
    SUM(salesRub) > 2000000 and
    fullname IS NOT NULL

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
