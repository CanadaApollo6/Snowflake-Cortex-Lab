/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - SELF-SERVICE SETUP
 *
 * Purpose: One-click setup for personal Snowflake trial accounts
 * Time: 2-3 minutes
 *
 * INSTRUCTIONS:
 * 1. Sign up for free Snowflake trial at signup.snowflake.com
 * 2. Log in to your trial account
 * 3. Create a new SQL worksheet
 * 4. Copy this entire file into the worksheet
 * 5. Click "Run All" (or press Ctrl/Cmd + Shift + Enter)
 * 6. Wait 2-3 minutes for completion
 * 7. Start with worksheet-01.sql!
 *
 * What this script does:
 * ✓ Creates warehouse and database
 * ✓ Grants Cortex AI privileges
 * ✓ Loads realistic sample data (4 tables)
 * ✓ Creates Cortex Search service
 * ✓ Verifies everything works
 *
 *******************************************************************************/

-- Use your trial account's default admin role
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE INFRASTRUCTURE (15 seconds)
-- ============================================================================

-- Create a small warehouse for learning (costs ~$1/hour when running)
CREATE WAREHOUSE IF NOT EXISTS CORTEX_LAB_WH
  WITH WAREHOUSE_SIZE = 'SMALL'
       AUTO_SUSPEND = 60        -- Stops after 1 minute of inactivity
       AUTO_RESUME = TRUE       -- Starts automatically when needed
       INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Cortex AI self-guided lab';

-- Create lab database
CREATE DATABASE IF NOT EXISTS LAB_DATA
  COMMENT = 'Cortex AI Lab - Self-Guided Learning';

USE DATABASE LAB_DATA;
USE WAREHOUSE CORTEX_LAB_WH;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS SAMPLES
  COMMENT = 'Sample datasets for learning';

CREATE SCHEMA IF NOT EXISTS CORTEX_SERVICES
  COMMENT = 'Cortex Search services';

CREATE SCHEMA IF NOT EXISTS MY_WORKSPACE
  COMMENT = 'Your personal workspace for experiments';

-- Grant Cortex AI privileges to yourself
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 2: LOAD SAMPLE DATA (60 seconds)
-- ============================================================================

USE SCHEMA SAMPLES;

-- Table 1: Customer Support Tickets (Multi-language)
CREATE OR REPLACE TABLE CUSTOMER_SUPPORT_TICKETS (
  ticket_id VARCHAR(20),
  customer_id VARCHAR(20),
  subject VARCHAR(500),
  description TEXT,
  language VARCHAR(10),
  priority VARCHAR(20),
  status VARCHAR(20),
  created_date TIMESTAMP,
  category VARCHAR(50),
  country VARCHAR(50)
);

INSERT INTO CUSTOMER_SUPPORT_TICKETS VALUES
-- English tickets
('TKT-001', 'CUST-1001', 'Package arrived damaged',
 'I ordered a laptop last week and it arrived today completely damaged. The box was crushed and the screen is cracked. This is absolutely unacceptable! I need a replacement immediately or a full refund. I have been a loyal customer for 5 years and this is the worst experience I have ever had with your company.',
 'en', 'high', 'open', '2024-10-01 09:15:00', 'shipping_damage', 'USA'),

('TKT-002', 'CUST-1002', 'Question about return policy',
 'Hi, I purchased a camera two weeks ago and I am not entirely satisfied with the image quality. It works fine but does not meet my professional needs. Can I return it for a refund? I still have the original packaging and all accessories. Thank you for your help.',
 'en', 'medium', 'open', '2024-10-02 14:30:00', 'returns', 'USA'),

('TKT-003', 'CUST-1003', 'Love the new headphones!',
 'Just wanted to say thank you! The wireless headphones I ordered arrived early and the sound quality is amazing. Best purchase I have made this year. Will definitely be ordering more products from you. Keep up the great work!',
 'en', 'low', 'closed', '2024-10-03 11:20:00', 'positive_feedback', 'Canada'),

-- Spanish tickets
('TKT-004', 'CUST-1004', 'Problema con el pago',
 'Intenté realizar un pago con mi tarjeta de crédito pero el sistema rechazó la transacción tres veces. Mi banco confirma que no hay problemas con mi tarjeta. ¿Pueden ayudarme a completar mi pedido? Necesito estos artículos urgentemente para un regalo.',
 'es', 'high', 'open', '2024-10-03 16:45:00', 'payment_issue', 'Spain'),

-- French tickets
('TKT-005', 'CUST-1005', 'Produit défectueux',
 'J''ai reçu mon ordinateur portable hier et il ne s''allume pas du tout. J''ai essayé différentes prises électriques et le chargeur ne fonctionne pas. C''est très frustrant car j''en ai besoin pour mon travail. Pouvez-vous m''envoyer un remplacement rapidement s''il vous plaît?',
 'fr', 'high', 'open', '2024-10-04 13:30:00', 'defective_product', 'France'),

-- German tickets
('TKT-006', 'CUST-1006', 'Falsche Artikel erhalten',
 'Ich habe gestern meine Bestellung erhalten, aber es waren die falschen Artikel in der Box. Ich habe eine Kamera bestellt, aber stattdessen Kopfhörer erhalten. Das ist sehr ärgerlich, da ich die Kamera für eine Veranstaltung am Wochenende brauche.',
 'de', 'high', 'open', '2024-10-05 15:20:00', 'wrong_item', 'Germany'),

-- More English tickets
('TKT-007', 'CUST-1007', 'Shipping address change needed',
 'I just placed an order 10 minutes ago but I need to change the shipping address. I accidentally used my old address. Can you update it to my new address before the order ships? Order number is ORD-98765.',
 'en', 'high', 'open', '2024-10-07 10:15:00', 'address_change', 'USA'),

('TKT-008', 'CUST-1008', 'Product recommendation request',
 'I am looking for a good laptop for video editing. My budget is around $1500. Can you recommend some options from your catalog? I need something with a powerful processor and good graphics card.',
 'en', 'low', 'open', '2024-10-07 14:00:00', 'product_inquiry', 'Australia');

-- Table 2: Product Reviews
CREATE OR REPLACE TABLE PRODUCT_REVIEWS (
  review_id VARCHAR(20),
  product_id VARCHAR(20),
  product_name VARCHAR(200),
  customer_id VARCHAR(20),
  rating INT,
  review_title VARCHAR(500),
  review_text TEXT,
  language VARCHAR(10),
  review_date TIMESTAMP,
  verified_purchase BOOLEAN,
  helpful_count INT
);

INSERT INTO PRODUCT_REVIEWS VALUES
('REV-001', 'PROD-101', 'UltraSound Pro Wireless Headphones', 'CUST-2001', 5,
 'Best headphones I have ever owned!',
 'These headphones are absolutely incredible. The noise cancellation is perfect for my daily commute, and the battery lasts for days. The sound quality is crisp and clear across all frequencies. Worth every penny.',
 'en', '2024-09-15 10:30:00', true, 245),

('REV-002', 'PROD-102', 'SmartCam 4K Security Camera', 'CUST-2002', 5,
 'Excelente cámara de seguridad',
 'La calidad de imagen es excepcional, incluso de noche. La instalación fue muy sencilla y la aplicación móvil funciona perfectamente. Me siento mucho más seguro con este sistema.',
 'es', '2024-09-18 14:20:00', true, 189),

('REV-003', 'PROD-103', 'PowerBook Elite Laptop', 'CUST-2003', 4,
 'Great laptop, minor issues',
 'Overall this is a fantastic laptop for the price. The performance is excellent and it handles all my work tasks smoothly. The only complaint is that the fan can get a bit loud when running intensive applications.',
 'en', '2024-09-20 09:15:00', true, 156),

('REV-004', 'PROD-104', 'FitTrack Smart Watch', 'CUST-2004', 3,
 'Decent but not great',
 'The watch does what it is supposed to do - tracks steps, heart rate, and sleep. However, the battery life is shorter than advertised and the app crashes occasionally. For the price, I expected better build quality.',
 'en', '2024-09-25 16:00:00', true, 98),

('REV-005', 'PROD-105', 'QuickCharge Power Bank', 'CUST-2005', 2,
 'Does not charge as advertised',
 'This power bank claims to charge my phone three times but it barely manages twice. The charging speed is also much slower than my regular charger. I would not recommend this product.',
 'en', '2024-09-28 10:00:00', true, 203),

('REV-006', 'PROD-104', 'FitTrack Smart Watch', 'CUST-2006', 1,
 'Broke after two weeks!',
 'This watch stopped working after only two weeks of normal use. The screen just went black and it will not turn on anymore. Customer service was unhelpful. Complete waste of money. Do not buy!',
 'en', '2024-10-01 15:20:00', true, 312);

-- Table 3: Product Documentation
CREATE OR REPLACE TABLE PRODUCT_DOCS (
  doc_id VARCHAR(20),
  product_id VARCHAR(20),
  doc_type VARCHAR(50),
  title VARCHAR(500),
  content TEXT,
  section VARCHAR(100),
  last_updated TIMESTAMP,
  author VARCHAR(100)
);

INSERT INTO PRODUCT_DOCS VALUES
('DOC-001', 'PROD-101', 'user_manual', 'UltraSound Pro - Getting Started',
 'Welcome to your new UltraSound Pro Wireless Headphones. CHARGING: Before first use, charge your headphones for at least 2 hours using the USB-C cable. The LED indicator will turn red while charging and green when fully charged. A full charge provides up to 30 hours of playback. PAIRING: Turn on the headphones by pressing and holding the power button for 3 seconds. The LED will flash blue indicating pairing mode. On your device, select UltraSound Pro from the Bluetooth settings. NOISE CANCELLATION: Press the ANC button once to enable noise cancellation, press again for transparency mode, and a third time to turn off ANC.',
 'setup', '2024-09-01 10:00:00', 'Technical Writing Team'),

('DOC-002', 'PROD-102', 'troubleshooting', 'SmartCam 4K - Common Issues',
 'CAMERA WON''T CONNECT TO WI-FI: Verify your Wi-Fi password is correct. Ensure you are using a 2.4GHz network. Move the camera closer to your router during setup. Restart your router and try again. POOR VIDEO QUALITY: Check your internet upload speed (minimum 5 Mbps for 4K). Lower the video quality setting in the app if bandwidth is limited. Ensure the camera lens is clean. NIGHT VISION NOT WORKING: The camera automatically enables night vision in low light. Clean the camera lens and infrared LEDs. Ensure Night Vision Mode is set to Auto in the app. The effective range is up to 30 feet.',
 'troubleshooting', '2024-09-10 16:30:00', 'Technical Support Team'),

('DOC-003', 'PROD-103', 'user_manual', 'PowerBook Elite - First Time Setup',
 'UNBOXING: Remove your PowerBook Elite from the box and verify all components: laptop, 65W USB-C power adapter, charging cable, quick start guide. FIRST BOOT: Connect the power adapter. Press the power button at the top-right of the keyboard. Follow the on-screen setup wizard. Select language, connect to Wi-Fi, create your user account. BATTERY OPTIMIZATION: Enable battery optimization in System Preferences. Adjust screen brightness to comfortable levels. Close unused applications. Use Battery Saver mode when unplugged. PERFORMANCE TIPS: Your PowerBook Elite features Intel Core i7, 16GB RAM, 512GB SSD. Keep at least 20% of storage free. Restart weekly. Update software regularly.',
 'setup', '2024-09-12 09:00:00', 'Technical Writing Team'),

('DOC-004', 'PROD-104', 'user_manual', 'FitTrack Smart Watch - Features Overview',
 'HEALTH TRACKING: Your FitTrack watch monitors heart rate 24/7, counts steps, tracks sleep stages (light, deep, REM), and estimates calories burned. EXERCISE MODES: 20+ modes including running, cycling, swimming (5ATM water resistant), yoga, and HIIT workouts. SMART FEATURES: Receive call, text, email, and app notifications. Control music playback. View weather forecast. Find My Phone feature triggers your phone to ring. BATTERY LIFE: Typical use: 5-7 days. Heavy use: 3-4 days. Battery saver mode: up to 10 days. Charges fully in 2 hours via magnetic charging cable.',
 'features', '2024-09-15 11:00:00', 'Technical Writing Team'),

('DOC-005', 'PROD-105', 'faq', 'QuickCharge Power Bank - FAQ',
 'Q: How many times can the QuickCharge 20000 charge my phone? A: The 20,000mAh capacity can charge most smartphones 3-4 times. iPhone 14: ~5 charges. Samsung S23: ~4 charges. Actual capacity is approximately 12,000-13,000mAh usable due to conversion loss. Q: How long to charge the power bank? A: With an 18W USB-C charger: approximately 6-7 hours. We recommend charging overnight. Q: Can I charge multiple devices? A: Yes! Features 2x USB-A outputs and 1x USB-C port. You can charge up to 3 devices simultaneously. Q: Is it safe for overnight charging? A: Yes, built-in overcharge protection automatically stops charging when devices reach 100%. Q: Airplane travel? A: Yes, 20,000mAh (74Wh) is under the TSA limit of 100Wh. Must be in carry-on, not checked luggage.',
 'faq', '2024-09-18 13:00:00', 'Customer Support Team');

-- Table 4: Sales Call Transcripts
CREATE OR REPLACE TABLE SALES_TRANSCRIPTS (
  call_id VARCHAR(20),
  sales_rep VARCHAR(100),
  customer_name VARCHAR(100),
  call_date TIMESTAMP,
  call_duration_minutes INT,
  transcript TEXT,
  outcome VARCHAR(50),
  product_discussed VARCHAR(100)
);

INSERT INTO SALES_TRANSCRIPTS VALUES
('CALL-001', 'Jennifer Martinez', 'ABC Corporation', '2024-10-01 14:00:00', 32,
 'Jennifer: Good afternoon! This is Jennifer from TechStore. Am I speaking with Michael Chen? Michael: Yes, that''s me. Jennifer: Thank you for your time. I understand you were interested in our PowerBook Elite laptop for your development team. Michael: Yes, we need about 15 new laptops. What differentiates your PowerBook from competitors? Jennifer: Great question. It features an 11th gen Intel i7, 16GB RAM, 512GB SSD, and a high-resolution display with 100% sRGB color accuracy. Michael: Our developers run multiple VMs and Docker containers. Will 16GB be sufficient? Jennifer: For your use case, I''d recommend our PowerBook Elite Pro with 32GB RAM. It''s about $400 more per unit but provides much better performance. Michael: I appreciate the honest recommendation. What about warranty? Jennifer: We offer 1-year warranty with next-business-day replacement. For corporate customers, we have 3-year extended warranty with on-site service. Given 15 units, I can offer 15% discount on extended warranty. Michael: Let me discuss with my team. Can you send a quote for both configurations? Jennifer: Absolutely! I''ll send that within the hour along with case studies. Michael: Perfect, thank you.',
 'proposal_sent', 'PowerBook Elite'),

('CALL-002', 'Maria Rodriguez', 'Downtown Fitness Center', '2024-10-03 15:45:00', 41,
 'Maria: Good afternoon! This is Maria from TechStore. Is this Karen? Karen: Yes, hi Maria. Maria: I wanted to follow up on our conversation about equipping your fitness center with FitTrack smartwatches for your premium membership program. Have you reviewed the proposal? Karen: Yes, and I''m very interested. Management is on board. We''d like to move forward with 50 watches. Maria: Fantastic news! The FitTrack watches will integrate seamlessly with your classes. Karen: Can we customize the watch faces with our gym logo? Maria: Absolutely! We offer custom branding for orders over 25 units at no additional charge. Karen: Perfect. What''s the delivery timeline? Maria: For 50 units with custom branding, approximately 3-4 weeks. We''ll send sample watch faces for your approval before full production. Karen: That works perfectly. We''re launching the new tier in early November. What are next steps? Maria: I''ll send the final contract this afternoon. Once signed, we''ll send the branding questionnaire. Our design team will create mockups within 3 business days. Karen: Excellent. Thank you Maria! Maria: Thank you so much, Karen!',
 'closed_won', 'FitTrack Smart Watch');

-- ============================================================================
-- STEP 3: CREATE CORTEX SEARCH SERVICE (60 seconds)
-- ============================================================================

USE SCHEMA CORTEX_SERVICES;

-- Create search service on product documentation
-- This enables semantic search for the RAG exercises
CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH
ON content
ATTRIBUTES title, doc_type
WAREHOUSE = CORTEX_LAB_WH
TARGET_LAG = '1 minute'
AS (
  SELECT
    doc_id,
    content,
    title,
    doc_type
  FROM LAB_DATA.SAMPLES.PRODUCT_DOCS
);

-- Note: The search service will take 30-60 seconds to index
-- You can continue with the worksheets while it indexes!

-- ============================================================================
-- STEP 4: VERIFICATION - Test Everything Works!
-- ============================================================================

USE SCHEMA SAMPLES;

-- Test 1: Count records in each table
SELECT 'CUSTOMER_SUPPORT_TICKETS' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_SUPPORT_TICKETS
UNION ALL
SELECT 'PRODUCT_REVIEWS', COUNT(*) FROM PRODUCT_REVIEWS
UNION ALL
SELECT 'PRODUCT_DOCS', COUNT(*) FROM PRODUCT_DOCS
UNION ALL
SELECT 'SALES_TRANSCRIPTS', COUNT(*) FROM SALES_TRANSCRIPTS;

-- Test 2: Verify Cortex functions work
SELECT
  'Cortex Functions Test' AS test_name,
  SNOWFLAKE.CORTEX.SENTIMENT('This is amazing! I love it!') AS sentiment_test,
  LEFT(SNOWFLAKE.CORTEX.TRANSLATE('Bonjour', 'fr', 'en'), 20) AS translate_test,
  'All systems operational!' AS status;

-- Test 3: Check if search service is ready
DESCRIBE CORTEX SEARCH SERVICE LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH;

-- ============================================================================
-- ✅ SETUP COMPLETE!
-- ============================================================================

/*
  🎉 Success! Your Cortex AI Lab is ready!

  WHAT WAS CREATED:
  ✓ Warehouse: CORTEX_LAB_WH (auto-suspends to save credits)
  ✓ Database: LAB_DATA
  ✓ Sample Data: 4 tables with realistic data
  ✓ Search Service: PRODUCT_DOCS_SEARCH (may still be indexing)
  ✓ Cortex Privileges: Granted to your account

  NEXT STEPS:

  1. Open worksheet-01.sql
     - Learn SENTIMENT, TRANSLATE, SUMMARIZE
     - 15 minutes of hands-on exercises

  2. Open worksheet-02.sql
     - Master CORTEX.COMPLETE for LLM tasks
     - 12 minutes of classification, extraction, generation

  3. Open worksheet-03.sql
     - Build semantic search and RAG patterns
     - 15 minutes core + advanced exercises

  COST ESTIMATE:
  - Completing all worksheets: < $1
  - This setup script: < $0.10
  - Your trial includes $400 in credits - plenty for learning!

  TIPS:
  - Warehouse auto-suspends after 60 seconds
  - Use SMALL warehouse for learning (already set)
  - Search service needs 30-60 seconds to index
  - All data persists - you can return anytime

  NEED HELP?
  - Check SELF_GUIDED_SETUP.md for troubleshooting
  - Visit docs.snowflake.com/cortex for documentation
  - Ask questions at community.snowflake.com

  Happy Learning! 🚀
*/
