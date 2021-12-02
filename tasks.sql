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
### Part 1 (singleSales)
*/

/*markdown
**1.** Рассчитать выручку компании в разрезе: Год – Месяц – Выручка компании. Представленные данные отсортировать: Год, Месяц
*/

SELECT TOP(5)
    companyName,
    YEAR(dateId) AS год,
    MONTH(dateId) AS месяц,
    SUM(salesRub) AS выручка
FROM
    distributor.singleSales
GROUP BY
    companyName,
    YEAR(dateId),
    MONTH(dateId)
ORDER BY
    YEAR(dateId),
    MONTH(dateId);

/*markdown
**2.** Рассчитать выручку компании в разрезе: Дата начало месяца – Выручка компании. Представление данных отсортировать: Дата начало месяца. В чем ключевое отличие от задачи №1?
*/

SELECT TOP(5) companyName,
               YEAR(dateId) AS год,
               MONTH(dateId) AS месяц,
               SUM(salesRub) AS выручка
FROM
    distributor.singleSales

WHERE DAY(dateId) = 1
group by
    companyName,
    YEAR(dateId),
    MONTH(dateId)
ORDER BY YEAR(dateId),
         MONTH(dateId);

/*markdown
**3.** Для каждой компании рассчитать среднее время между покупками, отдельно показать результат в днях и в месяцах.
*/

with temp(company, mn, mx, num) as (
    SELECT
        companyName,
        min(dateId),
        max(dateId),
        count(distinct checkId)
    FROM
        distributor.singleSales
    WHERE
        companyName IS NOT NULL
    GROUP BY
        companyName
)
select top(5)
    company,
    (datediff(month, mn, mx) / (num - 1)) as 'months',
    (datediff(day, mn, mx) / (num - 1)) as 'days'
FROM
    temp
where
    num - 1 != 0
ORDER BY
    months desc,
    days desc

/*markdown
**4.** Вывести результат задачи №2 только для 2013 года с наложением на столбец «Дата начало месяц» формат месяц. Т. е. я ожидаю увидеть в нем не даты, а январь, февраль, март и т. д.
*/

SELECT TOP(5)
    companyName,
    DateName(
        month,
        DateAdd(
            month,
            month(dateId) - 1,
            '1900-01-01'
        )
    ),
    SUM(salesRub) AS 'sales'
FROM
    distributor.singleSales
WHERE
    DAY(dateId) = 1
group by
    companyName,
    MONTH(dateId)
ORDER BY
    MONTH(dateId);

/*markdown
**5.** Разделить все компании на три сегмента:
- Очень давно не покупали – не было покупок более 365 дней от текущей даты
- Давно не покупали – не было покупок более 180 дней от текущей даты
- Не покупали – не было покупок более 90 дней от текущей даты
Текущею дату задать следующим образом: система должна брать существующею сегодня дату и смещать ее на 8 лет назад.
*/

DECLARE @start datetime;
set @start = (
    SELECT
        DateAdd(
            year,
            -10,
            GETDATE()
        )
);
DECLARE @start365 datetime;
set @start365 = (
    SELECT
        DateAdd(
            day,
            -365,
            @start
        )
);
DECLARE @start180 datetime;
set @start180 = (
    SELECT
        DateAdd(
            day,
            -180,
            @start
        )
);
DECLARE @start90 datetime;
set @start90 = (
    SELECT
        DateAdd(
            day,
            -90,
            @start
        )
);
with temp(company, mx) as (
    SELECT
        companyName,
        max(dateId)
    FROM
        distributor.singleSales
    WHERE
        dateId < @start
    GROUP BY
        companyName
)
SELECT TOP(10)
    company,
    iif(
        (mx < @start365),
        'category 1',
        iif(
            (mx < @start180),
            'category 2',
            iif(
                (mx < @start90),
                'category 3',
                'They bought recently.'
            )
        )
    ) as 'category'
FROM
    temp

/*markdown
**6.** Рассчитать выручку компании в разрезе: Год – Квартал – Выручка компании. Представленные данные отсортировать: Год, Квартал.
*/

SELECT TOP(5)
    companyName,
    YEAR(dateId) AS 'year',
    DATEPART(QUARTER, dateId) as 'q',
    SUM(salesRub) AS 'sales'
FROM
    distributor.singleSales
group by
    companyName,
    YEAR(dateId),
    DATEPART(QUARTER, dateId)
ORDER BY
    YEAR(dateId),
    DATEPART(QUARTER, dateId)

/*markdown
**7.** Необходимо проверить существование сезонной выручки внутри недели, для этого необходимо рассчитать выручку компании в разрезе: Год – День Недели – выручка компании. Представленные данные отсортировать: Год, день недели.
*/

SELECT TOP(5)
    companyName,
    YEAR(dateId) AS 'year',
    DATEPART(weekday, dateId) as 'day',
    SUM(salesRub) AS 'sales'
FROM
    distributor.singleSales
GROUP BY
    companyName,
    YEAR(dateId),
    DATEPART(weekday, dateId)
ORDER BY
    YEAR(dateId),
    DATEPART(weekday, dateId)

/*markdown
**8.** Найдите все компании, у которых в наименование есть «ООО», без учета регистра.
*/

SELECT TOP(5)
    companyName
FROM
    distributor.singleSales
WHERE
    companyName like '%ООО%' or
    companyName like '%ооо%'

/*markdown
**9.** Найдите все компании, у которых в наименование в начале стоит «ООО», без учета регистра и пробелов вначале.
*/

SELECT
    'No regex support in t-sql'

/*markdown
**10.** Необходимо разделить ФИ, что записаны в столбеце «fullName» на три столбца, выделив отдельно фамилию, имя и фамилия И.
*/

SELECT
    distinct top(5) fullname,
    SUBSTRING(
        fullname,
        1,
        CHARINDEX(' ', fullname) - 1
    ) AS 'surname',
    SUBSTRING(
        fullname,
        CHARINDEX(' ', fullname) + 1,
        LEN(fullname) - CHARINDEX(' ', fullname)
    ) AS 'name',
    SUBSTRING(
        fullname,
        1,
        CHARINDEX(' ', fullname) + 1
    ) + '.' AS 'surnameWithInitial'
FROM
    distributor.singleSales
WHERE
    fullname is not Null

/*markdown
### Part 2 (sales)
*/

/*markdown
**1.** Рассчитать выручку компании в разрезе: Год – Месяц – Филиал – Выручка компании. Представленные данные отсортировать: Филиал, Год, Месяц.
*/

SELECT TOP(5)
    branchName,
    year(dateId) as 'year',
    month(dateId) as 'month',
    sum(salesRub)
FROM
    distributor.sales
INNER JOIN
    distributor.branch on branch.branchId = sales.branchId
GROUP BY
    year(dateId),
    month(dateId),
    branchName
ORDER BY
    branchName,
    'year',
    'month'

/*markdown
**2.** Рассчитать выручку компании в разрезе: Филиал - Дата начало месяца – Выручка компании. Представление данных отсортировать: Филиал, Дата начало месяца.
*/

--

/*markdown
**11.** В таблицу: distributor.remains представлена информация об остатках, как : Филиал – Артикул товара – Дата – Остаток – СвободныйОстаток. Особенность заполнения данной таблицы, что если остаток на какую-то дату нулевой (для товара и филиала), то в таблицу он не заноситься, например: 2020-01-01 – 10шт., 2020-01-02 – 7шт. 2020-01-04 – 15 шт. Необходимо, восстановить пропуски в данной таблицы и дописать пропущенные значения. Из нашего примера: 2020-01-03 – 0 шт. Учтите, что даты складирования товара – филиала своя.
*/

SELECT TOP(10)
    *
FROM
    distributor.remains
WHERE
    remains = 0

/*markdown
**12.** Найти объём неликвидного товара в сравнение со всем товаром в шт. под неликвидом считается товар, который не продавался более 180 дней от текущей даты. Точку отсчета текущей даты взять за 2014-01-01.
*/

DECLARE @start datetime;
set @start = '2014-01-01';
DECLARE @start180 datetime;
set @start180 = (
    SELECT
        DateAdd(
            day,
            -180,
            @start
        )
);
with temp(itemId, mostRecentDateWhenItemWasSold) as (
    SELECT
        itemId,
        max(dateId)
    FROM
        distributor.sales
    WHERE
        dateId < @start
    GROUP BY
        itemId
),
temp2(itemId, liquidity) as (
    SELECT
        itemId,
        iif(
            mostRecentDateWhenItemWasSold < @start180,
            'non liquid',
            'liquid'
        )
    FROM
        temp
)
SELECT
    count(*) as 'Number of all items',
    (
        SELECT
            count(*)
        FROM
            temp2
        WHERE
            liquidity = 'non liquid'
    ) as 'Number of non-liquid items'
FROM
    temp

/*markdown
**13.** Определить топ 3 лучших товаров по выручки для каждого Бренда без учета времени, т. е. за всю историю работы компании.
*/

SELECT TOP(3)
    brand,
    itemName,
    sum(salesRub)
FROM
    distributor.sales
INNER JOIN
    distributor.item on (sales.itemId = item.itemId)
GROUP BY
    brand,
    itemName
ORDER BY
    sum(salesRub) desc

/*markdown
**14.** Определить топ 3 лучших товаров по выручке для каждого бренда с учетом временного интервала год.
*/

SELECT TOP(3)
    brand,
    left(itemName, 40) as 'item',
    sum(salesRub) as 'sum',
    year(dateID) as 'year'
FROM
    distributor.sales
INNER JOIN
    distributor.item on (sales.itemId = item.itemId)
GROUP BY
    brand,
    itemName,
    year(dateId)
ORDER BY
    'sum' desc

/*markdown
**15.** Определить долю вклада Топ 3 брендов в выручку компании без учета времени, т. е. за всю историю работы компании.
*/

with temp(brand, brandSales, brandRank) as (
    SELECT
        brand,
        sum(salesRub),
        RANK() OVER (ORDER BY sum(salesRub) DESC) brandRank
    FROM
        distributor.sales
    INNER JOIN
        distributor.item on (sales.itemId = item.itemId)
    WHERE
        companyId = 7322 -- ! we are doing it only for this company
    GROUP BY
        brand
)
SELECT
    sum(brandSales) / (
        SELECT
            sum(brandSales)
        FROM
            temp
    )
FROM
    temp
WHERE
    brandRank <= 3

/*markdown
**16.** Определить долю вклада Топ 3 брендов в выручку компании для каждого года и месяца.
*/

with base(year, month, brand, brandSales, brandRank) as (
    SELECT
        year(dateId),
        month(dateId),
        brand,
        sum(salesRub),
        row_number() OVER (
            partition by
                year(dateId),
                month(dateId)
            ORDER BY
                sum(salesRub) DESC
        ) brandRank
    FROM
        distributor.sales
    INNER JOIN
        distributor.item on (sales.itemId = item.itemId)
    WHERE
        companyId = 7322 -- ! we are doing it only for this company
    GROUP BY
        year(dateId),
        month(dateId),
        brand
),
temp2(year, month, brand, brandSales, brandRank) as (
    SELECT
        'year',
        'month',
        brand,
        sum(brandSales),
        brandRank
    FROM
        base
)
SELECT
    *
FROM
    temp2

/*markdown
**17.** Построить динамику изменения неликвидного товара по месяцам и по всем годам. Под неликвидом считается товар, который не продавался более 180 дней от текущей даты. Т. к. мы смотрим в динамике по месяцам, то для каждого месяца будет своя текущая дата, например, первый день месяца.
*/

-- todo

/*markdown
**26.** Вывести долю занимающих в продажах, различных фабрик.
  Если в товаре фабрика не указана, сделать замену на «иные» и так же вывести в долях.
  Нужно вывести как за весь период, так и в разрезе Год – Месяц (или дата начало месяца)
*/

-- For the whole time
with doli(dolya_item, fabrica) as (
    SELECT
        sum(quantity) as dolya_item,
        fabrica
    FROM
        (
            SELECT
                s.itemId,
                count(s.itemId) as quantity,
                fabrica
            FROM
                distributor.item i
            INNER JOIN
                distributor.sales s on i.itemId = s.itemId
            GROUP BY
                fabrica,
                s.itemId
        ) as tmp
    GROUP BY fabrica
)
SELECT TOP(10)
    cast(dolya_item as float) / cast(
        (
            SELECT
                sum(dolya_item)
            from
                doli
        ) as float
    ) as dolya,
    fabrica
FROM
    doli
GROUP BY
    dolya_item,
    fabrica

-- This is for Year/Month
with doli(dolya_item, fabrica, year, month) as (
    SELECT sum(quantity) as dolya_item, fabrica, year, month
             FROM (
                      SELECT
                             year(s.dateId) as year,
                             month(s.dateId) as month,
                             s.itemId,
                             count(s.itemId) as quantity,
                             fabrica
                      FROM distributor.item i
                             INNER JOIN distributor.sales s on i.itemId = s.itemId
                      GROUP BY year(s.dateId), month(s.dateId), fabrica, s.itemId
                  ) as tmp
             GROUP BY year, month, fabrica
)
SELECT TOP(10)
    cast(dolya_item as float) / cast(
        (SELECT sum(dolya_item) from doli) as float
        ) as dolya, fabrica
FROM
    doli
GROUP BY
    year, month, dolya_item, fabrica;

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
select TOP(5)
    (cast(temp1.sales as float) / cast(temp2.sales as float)) as boom
FROM
    temp1
INNER JOIN
    temp2 on temp1.month = temp2.month
