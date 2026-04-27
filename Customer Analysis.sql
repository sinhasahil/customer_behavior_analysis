SELECT * FROM customer
LIMIT 20;
--1. Top 5 Cities by Gross Revenue
SELECT city, ROUND(SUM(final_price)::numeric,2) AS gross_revenue, RANK() OVER (ORDER BY SUM(final_price) DESC) AS ranking FROM customer
GROUP BY city;

--2. Monthly Trend
SELECT EXTRACT (month FROM purchase_date) AS month_purchase_date, ROUND(SUM(final_price)::numeric,2) FROM customer
GROUP BY month_purchase_date;

--3. Return Rate by Category
SELECT category, ROUND(AVG(CASE WHEN is_returned = true THEN 1 ELSE 0 END)*100,2) AS return_rate FROM customer
GROUP BY category
ORDER BY return_rate DESC;

--4. Product Selling above Average Product Price
SELECT product_id, category, final_price FROM (SELECT product_id,category,final_price, AVG(final_price) OVER(PARTITION BY category) AS avg_price FROM customer)
WHERE final_price > avg_price;

--5. Device wise Customer Spending
SELECT device_type, COUNT(*) AS orders, ROUND(AVG(final_price)::numeric,2) AS avg_spend FROM customer
GROUP BY device_type
ORDER BY avg_spend DESC;

--6. Using CTE to find top seller in each category
SELECT seller_id, category, ROUND(sales::numeric,2),rn FROM( SELECT seller_id, category,sales, ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) as rn FROM (SELECT seller_id, category,SUM(final_price) AS sales FROM customer GROUP BY seller_id, category))
WHERE rn = 1;

--7. Delivery Status Performance
SELECT delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(shipping_time_days)::numeric,2) AS avg_days,
       ROUND(AVG(final_price)::numeric,2) AS avg_order_value
FROM customer
GROUP BY delivery_status;

--8. Find Repeat Cities with Highest Returns
SELECT city, COUNT(*) FILTER (WHERE is_returned=true) AS returns FROM customer
GROUP BY city
ORDER BY returns DESC;

--9. Products at Risk: High Demand but Low Stock
SELECT product_id,category,stock,review_count,rating,
       CASE
           WHEN stock < 50 AND review_count > 30 AND rating >= 4
           THEN 'Restock Urgently'
           WHEN stock < 100
           THEN 'Monitor'
           ELSE 'Healthy'
       END AS stock_status
FROM customer
ORDER BY stock ASC, review_count DESC;

--10. Best Performing Payment Method
SELECT payment_method,ROUND(SUM(final_price)::numeric,2) AS revenue,COUNT(*) AS total_orders FROM customer
GROUP BY payment_method
ORDER BY revenue DESC;