---Kategori bazlý gelir
SELECT p.category , SUM(od.quantity * od.unit_price) AS revenue FROM products p
JOIN orders_details od ON p.product_id=od.product_id
JOIN orders o ON o.order_id=od.order_id
WHERE o.order_status='Completed'
GROUP BY p.category 
ORDER BY revenue DESC;
---Gelirin büyük bölümü Caffe kategorisinde yoðunlaþmaktadýr;
---bu durum kategori baðýmlýlýðý riskine ve önceliklendirme fýrsatlarýna iþaret etmektedir.

---Ürün bazlý gelir dagýlýmý(pareto hazýrlýk analizi)
WITH product_revenue AS (
SELECT p.product_id  , p.product_name ,SUM(od.quantity * od.unit_price) AS revenue   FROM products p
JOIN orders_details od ON p.product_id=od.product_id
JOIN orders o ON o.order_id=od.order_id
WHERE o.order_status='Completed'
GROUP BY p.product_id , p.product_name
)
SELECT * FROM product_revenue
ORDER BY revenue DESC
---Gelirin önemli bir kýsmý Latte,Cappuccino ve  Flat White  ürünlerinde yoðunlaþmaktadýr;
---bu durum ürün bazlý gelir konsantrasyonuna ve sýnýrlý ürünlere baðýmlýlýk riskine iþaret etmektedir.

---Sube bazlý gelir dagýlýmý
SELECT b.branch_id ,b.branch_name ,b.opening_date, SUM(od.quantity * od.unit_price ) AS revenue FROM branches b 
JOIN orders o ON o.branch_id=b.branch_id
JOIN orders_details od ON od.order_id=o.order_id
WHERE o.order_status='Completed'
GROUP BY b.branch_id ,b.branch_name , b.opening_date
ORDER BY revenue DESC
---Daily Grind -Merkez þubesi en yüksek geliri üretmektedir; þube gelirlerinin açýlýþ tarihleriyle doðru orantýlý olmasý,
---operasyonel olgunluk süresinin gelir performansýný etkilediðini göstermektedir.

---Müsteri bazlý analiz : Siparis hacmi ve gelir katkýsý
SELECT c.customer_id,c.customer_name , SUM(od.quantity*od.unit_price) AS revenue , COUNT(DISTINCT o.order_id ) AS ordercount FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN orders_details od ON od.order_id=o.order_id
WHERE o.order_status='Completed'
GROUP BY c.customer_id,c.customer_name
ORDER BY revenue DESC
---Müþteri gelirleri sipariþ hacminden ziyade sipariþ baþýna düþen harcama tutarýyla ayrýþmaktadýr; 
---benzer sipariþ sayýlarýna sahip müþteriler arasýnda anlamlý gelir farklarý gözlemlenmektedir.

---Toplam ciro
SELECT SUM(od.quantity*od.unit_price) AS revenue FROM orders_details od 
JOIN orders o ON o.order_id=od.order_id
WHERE o.order_status='Completed';
---Analiz edilen dönemde, completed statüsündeki sipariþler üzerinden hesaplanan toplam gelir 95.370’dir.

---Düþük siparis -Yüksek gelir
SELECT c.customer_id ,c.customer_name ,SUM(od.quantity * od.unit_price) AS revenue , COUNT(DISTINCT o.order_id ) AS order_count FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN orders_details od ON od.order_id=o.order_id
WHERE o.order_status='Completed'
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(DISTINCT o.order_id ) <= 3
ORDER BY revenue DESC
---3 ve daha az sipariþ veren müþteriler arasýnda, en yüksek gelir saðlayan  ÝD C054 olan müþteri  1.645 gelir üretmiþtir.
---Bu durum, düþük sipariþ hacmine raðmen yüksek sepet deðeri oluþturan müþteri segmentinin varlýðýna iþaret etmektedir.

--- Gelir Younlasma riski(Top Customers)
SELECT TOP 5 c.customer_id,c.customer_name ,SUM(od.quantity*od.unit_price) AS revenue  FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN orders_details od ON od.order_id=o.order_id
WHERE o.order_status='Completed'
GROUP BY c.customer_id,c.customer_name
ORDER BY revenue DESC;
---Gelirin önemli bir kýsmý C051, C067, C015, C092 ve C074 müþteri ID’lerinde yoðunlaþmaktadýr. 
---Bu durum, gelir yoðunlaþma riskine iþaret etmektedir.


--- Pareto Analizi
WITH costomerciro AS(
SELECT c.customer_id,SUM(od.quantity*od.unit_price) AS revenue FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
JOIN orders_details od ON od.order_id=o.order_id
WHERE o.order_status='Completed'
GROUP BY c.customer_id
), 
ranted_ciro AS 
(
SELECT customer_id , revenue ,SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_ciro , 
SUM(revenue) OVER () AS total_ciro  FROM costomerciro
)
SELECT customer_id , revenue , cumulative_ciro , total_ciro ,
cumulative_ciro * 1.00 / total_ciro AS cumulative_ratio
FROM ranted_ciro
WHERE cumulative_ciro * 1.00 / total_ciro <= 0.80
ORDER BY revenue DESC;
---Toplam gelirin yaklaþýk %80’i müþteri tabanýnýn %60’ý tarafýndan üretilmektedir. Bu daðýlým,
---gelirin tekil müþterilerde aþýrý yoðunlaþmadýðýný ancak üst müþteri segmentinin gelir açýsýndan kritik olduðunu göstermektedir.





