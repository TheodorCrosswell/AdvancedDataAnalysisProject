# SQL Advanced Data Analysis Project

This repository showcases an advanced data analysis project using SQL, focused on deriving actionable business insights from a sales dataset. The primary objective is to transform raw sales data into comprehensive, aggregated reports that reveal customer behaviors and product performance.

The centerpiece of this project is the `reports` folder, which contains production-ready SQL scripts designed to be modular, efficient, and easily maintainable. Other scripts in the repository document the learning process and demonstrate various standalone analytical techniques.

---

## 🚀 Skills Demonstrated

This project showcases a strong command of modern SQL for data analysis and reporting:

*   **Advanced SQL Querying:**
    *   **Common Table Expressions (CTEs):** Extensively used to build logical, readable, and modular queries. This approach breaks down complex logic into sequential, understandable steps.
    *   **Window Functions:** Utilized `LAG()`, `SUM() OVER`, `AVG() OVER`, and `PARTITION BY` to perform sophisticated analyses like year-over-year performance, cumulative totals, and rolling averages.

*   **Data Aggregation & Transformation:**
    *   **Complex Aggregations:** Proficient use of `GROUP BY` with functions like `COUNT(DISTINCT)`, `SUM`, `AVG`, `MIN`, and `MAX` to consolidate data into meaningful summaries.
    *   **Data Segmentation:** Implemented `CASE` statements to create custom business segments, such as `VIP`/`Regular`/`New` customers and `High-Performer`/`Mid-Range` products.
    *   **Date/Time Manipulation:** Leveraged `DATEDIFF`, `GETDATE`, `DATEPART`, and `DATETRUNC` to conduct time-series analysis, calculate customer lifespans, and measure recency.

*   **Data Modeling & Reporting:**
    *   **View Creation:** Designed and created SQL `VIEW`s (`gold.report_customers`, `gold.report_products`) to provide a stable, pre-aggregated data source for BI tools (like Power BI, Tableau) or further ad-hoc analysis. This promotes a single source of truth.
    *   **KPI Calculation:** Engineered key performance indicators (KPIs) directly within SQL, such as Average Order Value (AOV), Average Monthly Spend, and Recency.

*   **Code Quality & Best Practices:**
    *   **Readability & Maintainability:** Wrote clean, well-commented, and logically structured SQL code.
    *   **Query Optimization:** Demonstrated an understanding of efficient query writing by preferring `GROUP BY` for aggregations over less efficient window function approaches (as detailed in the [Code Evolution](#-code-evolution-from-messy-to-modular) section).

---

## ✨ Showcase: The `reports` Folder

This folder contains the final, polished analytical outputs of the project. The scripts are designed to be both ad-hoc reports and the foundation for reusable SQL views.

### 1. Customer Report (`customer_report.sql` & `create_view_report_customer.sql`)

This report provides a 360-degree view of each customer, transforming raw transaction data into a rich customer profile.

*   **Purpose:** To consolidate key customer metrics and segment customers based on their behavior and demographics.
*   **Key Metrics Calculated:**
    *   `customer_total_orders`
    *   `customer_total_sales`
    *   `customer_total_quantity`
    *   `customer_lifespan_months`
    *   `customer_months_since_last_order` (Recency)
*   **Calculated KPIs:**
    *   `customer_average_order_value` (AOV)
    *   `customer_average_monthly_spending`
*   **Custom Segments:**
    *   **Spending Segment:** `VIP`, `Regular`, `New`
    *   **Age Segment:** `Minor`, `Young Adult`, `Middle-aged`, etc.

### 2. Product Report (`product_report.sql` & `create_view_report_product.sql`)

This report analyzes product performance from multiple angles, identifying top sellers and assessing their lifecycle.

*   **Purpose:** To consolidate key product metrics and segment products based on their revenue generation.
*   **Key Metrics Calculated:**
    *   `product_total_orders`
    *   `product_total_sales`
    *   `product_total_unique_customers`
    *   `product_lifespan_months`
    *   `product_months_since_last_sale` (Recency)
*   **Calculated KPIs:**
    *   `product_average_order_revenue`
    *   `product_average_monthly_revenue`
*   **Custom Segments:**
    *   **Product Segment:** `High-Performer`, `Mid-Range`, `Low-Performer`

---

## 🎓 Learning & Development Scripts

The `scripts/` folder contains standalone queries used to practice and demonstrate specific analytical techniques, such as:
*   **Change Over Time Analysis:** Calculating year-over-year and month-over-month percentage changes in sales, customers, and quantity.
*   **Cumulative Analysis:** Calculating running totals and rolling averages.
*   **Performance Analysis:** Comparing a product's yearly sales against its historical average and the previous year's performance.
*   **Part-to-Whole Analysis:** Determining the percentage contribution of each product category to total sales.

---

## 🔄 Code Evolution: From Messy to Modular

A key part of developing analytical skills is learning to write code that is not only correct but also efficient and maintainable. The `unused_scripts/customer_report1.sql` file represents an early draft of the customer report, while `reports/customer_report.sql` is the final, vastly improved version.

This evolution highlights a deliberate move toward SQL best practices.

### The Problem with the Initial Approach (`customer_report1.sql`)

The first version of the query was functional but suffered from several issues:

1.  **Inefficient Aggregations:** It used window functions (`SUM() OVER (PARTITION BY ...)` a total of 8 times) to calculate customer-level totals. This computes the same total for *every single row* belonging to a customer, creating a massive, denormalized intermediate result set. This is computationally expensive and memory-intensive.
2.  **Monolithic Logic:** All calculations were crammed into a single CTE, making the query difficult to read, debug, and modify.
3.  **Incorrect Logic:** The calculation for `customer_total_unique_products` was flawed, as `COUNT(product_number) OVER (...)` does not count distinct products correctly in that context.

### The Improved, Modular Solution (`customer_report.sql`)

The final version addresses all these issues by adopting a more structured and efficient approach:

| Improvement | Inefficient Approach (`customer_report1.sql`) | Best Practice (`customer_report.sql`) |
| :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Modularity** | A single, monolithic CTE mixes data selection, aggregation, and calculation, making it hard to follow. | Uses a chain of three CTEs (`base_query`, `aggregations`, `final_transformations`), each with a clear, single purpose. The logic is easy to trace. |
| **Efficiency** | Uses window functions for aggregations, which is highly inefficient for collapsing rows. | Uses a standard **`GROUP BY`** clause in the `aggregations` CTE. This correctly and efficiently collapses the data to one row per customer early on. |
| **Clarity & Readability** | Logic is tangled. Debugging requires running the entire complex query. | Each CTE can be run independently to validate intermediate results, making debugging simple and intuitive. |
| **Accuracy** | Flawed logic for counting unique products. | Uses **`COUNT(DISTINCT product_number)`** within the `GROUP BY` to ensure the metric is calculated accurately. |

By refactoring the query, the final report is not only more accurate but also significantly faster and easier for other developers to understand and maintain. This demonstrates a mature understanding of SQL for real-world data engineering and analysis.
