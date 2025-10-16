/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - SAMPLE DATA LOADING
 * 
 * Purpose: Load realistic sample datasets that showcase Cortex capabilities
 * 
 * Datasets Created:
 * 1. CUSTOMER_SUPPORT_TICKETS - Multi-language support tickets
 * 2. PRODUCT_REVIEWS - Customer reviews with sentiment
 * 3. PRODUCT_DOCS - Knowledge base articles for search
 * 4. SALES_TRANSCRIPTS - Call transcripts for summarization
 * 
 * Prerequisites:
 * - Provisioning script has been run
 * - Running as ACCOUNTADMIN or role with CREATE TABLE privileges
 * 
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE LAB_DATA;
USE SCHEMA SAMPLES;
USE WAREHOUSE CORTEX_LAB_WH;

-- ============================================================================
-- DATASET 1: CUSTOMER SUPPORT TICKETS
-- Multi-language, varying sentiment, needs summarization and categorization
-- ============================================================================

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

-- Insert realistic support tickets
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

('TKT-005', 'CUST-1005', 'Consulta sobre envío internacional',
 'Buenos días, me gustaría saber si realizan envíos a Argentina y cuánto tiempo demora aproximadamente. Estoy interesado en comprar varios productos electrónicos. ¿Tienen algún costo adicional por envío internacional?',
 'es', 'medium', 'open', '2024-10-04 10:00:00', 'shipping_inquiry', 'Argentina'),

-- French tickets
('TKT-006', 'CUST-1006', 'Produit défectueux',
 'J''ai reçu mon ordinateur portable hier et il ne s''allume pas du tout. J''ai essayé différentes prises électriques et le chargeur ne fonctionne pas. C''est très frustrant car j''en ai besoin pour mon travail. Pouvez-vous m''envoyer un remplacement rapidement s''il vous plaît?',
 'fr', 'high', 'open', '2024-10-04 13:30:00', 'defective_product', 'France'),

('TKT-007', 'CUST-1007', 'Excellente expérience',
 'Je voulais simplement vous remercier pour le service client exceptionnel. Mon colis est arrivé en parfait état et plus tôt que prévu. La qualité des produits est excellente. Je recommanderai certainement votre entreprise à mes amis et collègues.',
 'fr', 'low', 'closed', '2024-10-05 09:00:00', 'positive_feedback', 'France'),

-- German tickets
('TKT-008', 'CUST-1008', 'Falsche Artikel erhalten',
 'Ich habe gestern meine Bestellung erhalten, aber es waren die falschen Artikel in der Box. Ich habe eine Kamera bestellt, aber stattdessen Kopfhörer erhalten. Das ist sehr ärgerlich, da ich die Kamera für eine Veranstaltung am Wochenende brauche. Bitte senden Sie mir so schnell wie möglich die richtige Bestellung.',
 'de', 'high', 'open', '2024-10-05 15:20:00', 'wrong_item', 'Germany'),

-- Japanese tickets
('TKT-009', 'CUST-1009', '配送の遅延について',
 '先週注文した商品がまだ届いていません。追跡番号を確認したところ、配送が遅れているようです。できるだけ早く配送状況を確認していただけますか。この商品は誕生日プレゼント用なので、早く受け取りたいです。',
 'ja', 'medium', 'open', '2024-10-06 08:00:00', 'delivery_delay', 'Japan'),

-- Chinese tickets
('TKT-010', 'CUST-1010', '产品质量问题',
 '我购买的耳机音质很差，而且连接不稳定。我看了很多好评才决定购买的，但实际使用体验与描述完全不符。我想申请退款。请尽快处理我的请求，谢谢。',
 'zh', 'medium', 'open', '2024-10-06 12:30:00', 'quality_issue', 'China'),

-- More English tickets for variety
('TKT-011', 'CUST-1011', 'Shipping address change needed',
 'I just placed an order 10 minutes ago but I need to change the shipping address. I accidentally used my old address. Can you update it to my new address before the order ships? Order number is ORD-98765. Please confirm once updated.',
 'en', 'high', 'open', '2024-10-07 10:15:00', 'address_change', 'USA'),

('TKT-012', 'CUST-1012', 'Discount code not working',
 'I am trying to use the promotional code SAVE20 that I received in an email, but it keeps saying the code is invalid. The email says it is valid until October 15th. Can you help me apply this discount to my cart? I have several items ready to purchase.',
 'en', 'medium', 'open', '2024-10-07 11:45:00', 'promo_code_issue', 'UK'),

('TKT-013', 'CUST-1013', 'Product recommendation request',
 'I am looking for a good laptop for video editing. My budget is around $1500. Can you recommend some options from your catalog? I need something with a powerful processor and good graphics card. Also, how long does shipping usually take?',
 'en', 'low', 'open', '2024-10-07 14:00:00', 'product_inquiry', 'Australia'),

('TKT-014', 'CUST-1014', 'Missing items in order',
 'My order arrived today but two items are missing. I ordered three items total but only one was in the box. The packing slip shows all three items. Where are my other products? This is order ORD-12345. Please send the missing items or issue a refund.',
 'en', 'high', 'open', '2024-10-07 16:20:00', 'missing_items', 'Canada'),

('TKT-015', 'CUST-1015', 'Outstanding customer service!',
 'I want to give special recognition to Sarah from your customer support team. She went above and beyond to help me track down a lost package and even expedited a replacement at no extra charge. This is the kind of service that keeps customers coming back. Thank you!',
 'en', 'low', 'closed', '2024-10-07 17:30:00', 'positive_feedback', 'USA');

-- ============================================================================
-- DATASET 2: PRODUCT REVIEWS
-- Multi-language reviews with clear sentiment for analysis
-- ============================================================================

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
-- 5-star reviews
('REV-001', 'PROD-101', 'UltraSound Pro Wireless Headphones', 'CUST-2001', 5,
 'Best headphones I have ever owned!',
 'These headphones are absolutely incredible. The noise cancellation is perfect for my daily commute, and the battery lasts for days. The sound quality is crisp and clear across all frequencies. Worth every penny. I have recommended these to all my friends and family.',
 'en', '2024-09-15 10:30:00', true, 245),

('REV-002', 'PROD-102', 'SmartCam 4K Security Camera', 'CUST-2002', 5,
 'Excelente cámara de seguridad',
 'La calidad de imagen es excepcional, incluso de noche. La instalación fue muy sencilla y la aplicación móvil funciona perfectamente. Me siento mucho más seguro con este sistema. La relación calidad-precio es inmejorable. Totalmente recomendada.',
 'es', '2024-09-18 14:20:00', true, 189),

-- 4-star reviews
('REV-003', 'PROD-103', 'PowerBook Elite Laptop', 'CUST-2003', 4,
 'Great laptop, minor issues',
 'Overall this is a fantastic laptop for the price. The performance is excellent and it handles all my work tasks smoothly. The only complaint is that the fan can get a bit loud when running intensive applications. Battery life is good, usually gets me through a full workday. Would recommend for business users.',
 'en', '2024-09-20 09:15:00', true, 156),

('REV-004', 'PROD-101', 'UltraSound Pro Wireless Headphones', 'CUST-2004', 4,
 'Très bon produit mais cher',
 'La qualité sonore est excellente et le confort est au rendez-vous même après plusieurs heures d''utilisation. La réduction de bruit fonctionne très bien. Mon seul reproche est le prix qui est assez élevé. Si vous avez le budget, ces écouteurs en valent la peine.',
 'fr', '2024-09-22 11:45:00', true, 134),

-- 3-star reviews
('REV-005', 'PROD-104', 'FitTrack Smart Watch', 'CUST-2005', 3,
 'Decent but not great',
 'The watch does what it is supposed to do - tracks steps, heart rate, and sleep. However, the battery life is shorter than advertised and the app crashes occasionally. For the price, I expected better build quality. The screen scratches easily. It is okay but there are probably better options available.',
 'en', '2024-09-25 16:00:00', true, 98),

('REV-006', 'PROD-102', 'SmartCam 4K Security Camera', 'CUST-2006', 3,
 'Funktioniert gut, aber Verbindungsprobleme',
 'Die Bildqualität ist gut und die Einrichtung war einfach. Allerdings verliert die Kamera manchmal die WLAN-Verbindung und muss neu gestartet werden. Der Kundenservice war hilfreich, aber das Problem besteht weiterhin. Für den Preis hätte ich eine stabilere Verbindung erwartet.',
 'de', '2024-09-27 13:30:00', true, 87),

-- 2-star reviews
('REV-007', 'PROD-105', 'QuickCharge Power Bank', 'CUST-2007', 2,
 'Does not charge as advertised',
 'This power bank claims to charge my phone three times but it barely manages twice. The charging speed is also much slower than my regular charger. The build quality feels cheap and plasticky. I would not recommend this product. There are better options for the same price.',
 'en', '2024-09-28 10:00:00', true, 203),

('REV-008', 'PROD-103', 'PowerBook Elite Laptop', 'CUST-2008', 2,
 '期待外れでした',
 'レビューを見て購入しましたが、実際の性能は期待以下でした。起動が遅く、アプリケーションの動作も重いです。バッテリーの持ちも広告ほど良くありません。この価格帯なら他にもっと良い選択肢があると思います。',
 'ja', '2024-09-29 08:45:00', true, 176),

-- 1-star reviews
('REV-009', 'PROD-104', 'FitTrack Smart Watch', 'CUST-2009', 1,
 'Broke after two weeks!',
 'This watch stopped working after only two weeks of normal use. The screen just went black and it will not turn on anymore. Customer service was unhelpful and slow to respond. Complete waste of money. Do not buy this product! I am extremely disappointed and angry.',
 'en', '2024-10-01 15:20:00', true, 312),

('REV-010', 'PROD-105', 'QuickCharge Power Bank', 'CUST-2010', 1,
 '完全な粗悪品',
 '購入して1週間で充電できなくなりました。返金を求めましたが、対応が非常に遅いです。この製品は全くお勧めできません。お金の無駄でした。他の製品を購入することをお勧めします。',
 'ja', '2024-10-02 09:30:00', true, 267),

-- More mixed reviews
('REV-011', 'PROD-101', 'UltraSound Pro Wireless Headphones', 'CUST-2011', 5,
 '物超所值的耳机',
 '音质非常出色，降噪效果很好。佩戴舒适，即使长时间使用也不会感到不适。电池续航能力强，充一次电可以用好几天。强烈推荐给需要高品质耳机的朋友们。这是我买过最好的耳机。',
 'zh', '2024-10-03 12:00:00', true, 198),

('REV-012', 'PROD-102', 'SmartCam 4K Security Camera', 'CUST-2012', 4,
 'Good value for money',
 'For the price, this camera offers excellent features. The 4K resolution is impressive and the night vision works well. Setup was straightforward with the mobile app. My only complaint is that the motion detection can be a bit too sensitive, triggering false alarms. Overall, a solid purchase.',
 'en', '2024-10-04 14:30:00', true, 142),

('REV-013', 'PROD-103', 'PowerBook Elite Laptop', 'CUST-2013', 5,
 'Perfect for professional work',
 'I use this laptop for software development and it handles everything I throw at it. Multiple IDEs, virtual machines, Docker containers - no problem. The keyboard is comfortable for long coding sessions. The display is bright and color-accurate. Highly recommended for developers and creative professionals.',
 'en', '2024-10-05 11:00:00', true, 221),

('REV-014', 'PROD-104', 'FitTrack Smart Watch', 'CUST-2014', 4,
 'Bon rapport qualité-prix',
 'Pour le prix, cette montre offre de bonnes fonctionnalités. Le suivi de la condition physique est précis et l''interface est intuitive. La durée de vie de la batterie pourrait être meilleure, mais c''est acceptable. Je la recommande pour ceux qui veulent une montre connectée sans dépenser une fortune.',
 'fr', '2024-10-06 16:15:00', true, 167),

('REV-015', 'PROD-105', 'QuickCharge Power Bank', 'CUST-2015', 3,
 'Average performance',
 'This power bank does the job but nothing exceptional. Charges my phone about 2-3 times as claimed. The charging speed is okay but not fast. Build quality is acceptable. For the price, it is a reasonable purchase if you need a basic portable charger. There are fancier options if you want to spend more.',
 'en', '2024-10-07 13:45:00', true, 94);

-- ============================================================================
-- DATASET 3: PRODUCT DOCUMENTATION / KNOWLEDGE BASE
-- For Cortex Search and RAG demonstrations
-- ============================================================================

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
 'Welcome to your new UltraSound Pro Wireless Headphones. This guide will help you set up and start using your headphones in minutes. 

WHAT IS IN THE BOX:
- UltraSound Pro Headphones
- USB-C charging cable
- 3.5mm audio cable (for wired mode)
- Carrying case
- Quick start guide

CHARGING YOUR HEADPHONES:
Before first use, charge your headphones for at least 2 hours. Connect the USB-C cable to the charging port located on the right earcup. The LED indicator will turn red while charging and green when fully charged. A full charge provides up to 30 hours of playback time.

PAIRING WITH YOUR DEVICE:
1. Turn on the headphones by pressing and holding the power button for 3 seconds
2. The LED will flash blue, indicating pairing mode
3. On your device, go to Bluetooth settings
4. Select "UltraSound Pro" from the list of available devices
5. Once connected, you will hear a confirmation tone

The headphones will automatically reconnect to the last paired device when turned on.',
 'setup', '2024-09-01 10:00:00', 'Technical Writing Team'),

('DOC-002', 'PROD-101', 'user_manual', 'UltraSound Pro - Noise Cancellation',
 'ACTIVE NOISE CANCELLATION (ANC):
Your UltraSound Pro headphones feature advanced active noise cancellation technology that reduces ambient noise by up to 35dB.

HOW TO USE ANC:
- Press the ANC button once to enable noise cancellation
- Press again to enable transparency mode (hear your surroundings)
- Press a third time to turn off ANC

ANC MODES EXPLAINED:
NOISE CANCELLATION MODE: Blocks out ambient noise for immersive listening. Ideal for flights, commutes, or noisy environments. This mode uses the most battery power.

TRANSPARENCY MODE: Allows ambient sound to pass through while you listen to music. Perfect for staying aware of your surroundings while walking or when you need to hear announcements.

OFF MODE: Disables all processing for maximum battery life. Use this mode when in quiet environments.

TIPS FOR BEST PERFORMANCE:
- Ensure earcups form a proper seal around your ears
- ANC works best with consistent background noise like airplane engines or air conditioning
- For sudden loud noises, transparency mode may be more comfortable
- ANC slightly reduces battery life; you can expect 24-26 hours with ANC on vs 30 hours with it off',
 'features', '2024-09-01 10:00:00', 'Technical Writing Team'),

('DOC-003', 'PROD-102', 'user_manual', 'SmartCam 4K - Installation Guide',
 'SMARTCAM 4K SECURITY CAMERA - INSTALLATION

BEFORE YOU BEGIN:
- Ensure you have a stable Wi-Fi connection (2.4GHz or 5GHz)
- Download the SmartCam app from the App Store or Google Play
- Have your Wi-Fi password ready
- Charge the camera fully before installation (about 3 hours)

CHOOSING A LOCATION:
Select a mounting location that provides:
- Clear view of the area you want to monitor
- Access to power outlet (for wired mode) or good battery access (for wireless mode)
- Strong Wi-Fi signal (test with your phone at the intended location)
- Protection from direct rain (if outdoor installation)
- Height of 7-10 feet for optimal viewing angle

INSTALLATION STEPS:
1. Open the SmartCam app and create an account
2. Tap "Add New Device" and select "SmartCam 4K"
3. Scan the QR code on the back of the camera
4. Follow the in-app instructions to connect to Wi-Fi
5. Once connected, mount the camera using the included bracket
6. Adjust the viewing angle using the ball joint
7. Configure motion detection zones and notification settings in the app

MOTION DETECTION SETUP:
The camera uses advanced AI to distinguish between people, vehicles, and animals. In the app:
- Draw motion detection zones on the camera feed
- Set sensitivity levels (Low, Medium, High)
- Choose what to detect: People, Vehicles, Animals, or All Motion
- Configure notification preferences

The camera will send alerts to your phone when motion is detected in the specified zones.',
 'setup', '2024-09-05 14:00:00', 'Technical Writing Team'),

('DOC-004', 'PROD-102', 'troubleshooting', 'SmartCam 4K - Common Issues',
 'TROUBLESHOOTING GUIDE - SMARTCAM 4K

CAMERA WON''T CONNECT TO WI-FI:
- Verify your Wi-Fi password is correct
- Ensure you are using a 2.4GHz network (5GHz networks may have shorter range)
- Move the camera closer to your router during setup
- Restart your router and try again
- Disable MAC address filtering temporarily on your router
- Check if your router firewall is blocking the camera

POOR VIDEO QUALITY:
- Check your internet upload speed (minimum 5 Mbps recommended for 4K)
- Lower the video quality setting in the app if bandwidth is limited
- Ensure the camera lens is clean
- Verify the camera is within good Wi-Fi range
- Try switching between 2.4GHz and 5GHz networks

FREQUENT FALSE MOTION ALERTS:
- Reduce motion detection sensitivity in the app
- Refine your motion detection zones to exclude trees, flags, or busy streets
- Enable AI detection to filter out non-relevant motion
- Adjust the detection schedule to avoid windy periods
- Ensure the camera is mounted securely and not moving

NIGHT VISION NOT WORKING:
- The camera automatically enables night vision in low light
- Clean the camera lens and infrared LEDs
- Ensure "Night Vision Mode" is set to "Auto" in the app
- Check if there are reflective surfaces nearby causing glare
- The effective night vision range is up to 30 feet

BATTERY DRAINING QUICKLY:
- Reduce video quality to 1080p to save power
- Decrease motion detection sensitivity
- Limit the number of motion zones
- Enable sleep mode during times when monitoring is not needed
- Consider switching to wired power for 24/7 recording',
 'troubleshooting', '2024-09-10 16:30:00', 'Technical Support Team'),

('DOC-005', 'PROD-103', 'user_manual', 'PowerBook Elite - First Time Setup',
 'POWERBOOK ELITE LAPTOP - INITIAL SETUP

UNBOXING AND INSPECTION:
Carefully remove your PowerBook Elite from the box and verify all components:
- PowerBook Elite Laptop
- 65W USB-C Power Adapter
- USB-C Charging Cable
- Quick Start Guide
- Warranty Information

Inspect the laptop for any physical damage before powering on.

FIRST BOOT:
1. Connect the power adapter to charge the battery
2. Press the power button located at the top-right of the keyboard
3. Follow the on-screen setup wizard
4. Select your language and region
5. Connect to your Wi-Fi network
6. Create your user account
7. Configure privacy settings

RECOMMENDED INITIAL CONFIGURATION:
- Enable FileVault disk encryption for data security
- Set up Touch ID for quick login
- Configure automatic backups
- Install system updates
- Create a recovery key and store it safely

BATTERY OPTIMIZATION:
For best battery life:
- Enable battery optimization in System Preferences
- Adjust screen brightness to comfortable levels (not maximum)
- Close unused applications
- Disable Bluetooth when not in use
- Use Battery Saver mode when unplugged

PERFORMANCE TIPS:
Your PowerBook Elite features:
- Intel Core i7 processor (11th Gen)
- 16GB RAM
- 512GB SSD
- Intel Iris Xe Graphics

For optimal performance:
- Keep at least 20% of storage free
- Restart the laptop weekly
- Run disk cleanup monthly
- Update software regularly
- Use Activity Monitor to identify resource-heavy apps',
 'setup', '2024-09-12 09:00:00', 'Technical Writing Team'),

('DOC-006', 'PROD-104', 'user_manual', 'FitTrack Smart Watch - Features Overview',
 'FITTRACK SMART WATCH - COMPLETE FEATURES GUIDE

HEALTH & FITNESS TRACKING:
Your FitTrack watch monitors:

HEART RATE: Continuous 24/7 heart rate monitoring using advanced optical sensors. View real-time heart rate on the watch face or detailed analytics in the app.

STEP COUNTING: Accurate step tracking using 3-axis accelerometer. Daily step goals can be customized in the FitTrack app.

SLEEP TRACKING: Automatic sleep detection tracks sleep duration, sleep stages (light, deep, REM), and sleep quality score. View detailed sleep analysis each morning.

CALORIE BURN: Estimates calories burned based on your activity level, heart rate, age, weight, and height.

EXERCISE MODES: 20+ exercise modes including:
- Running (outdoor/indoor)
- Cycling
- Swimming (5ATM water resistant)
- Yoga
- Strength training
- HIIT workouts

SMART FEATURES:
NOTIFICATIONS: Receive call, text, email, and app notifications directly on your wrist. Compatible with iOS and Android.

MUSIC CONTROL: Control music playback on your phone without taking it out of your pocket.

WEATHER: View current weather and 3-day forecast on your watch.

FIND MY PHONE: Trigger your phone to ring even if it is on silent mode.

BATTERY LIFE:
- Typical use: 5-7 days
- Heavy use: 3-4 days
- Battery saver mode: up to 10 days
- Charges fully in 2 hours via magnetic charging cable

WATER RESISTANCE:
5ATM rated - suitable for swimming in pools and shallow water. Not suitable for scuba diving or high-pressure water activities.',
 'features', '2024-09-15 11:00:00', 'Technical Writing Team'),

('DOC-007', 'PROD-105', 'faq', 'QuickCharge Power Bank - Frequently Asked Questions',
 'QUICKCHARGE POWER BANK - FAQ

Q: How many times can the QuickCharge 20000 charge my phone?
A: The 20,000mAh capacity can charge most smartphones 3-4 times. Exact number depends on your phone''s battery size. For example:
- iPhone 14 (3,279mAh): ~5 charges
- Samsung S23 (3,900mAh): ~4 charges
- iPhone 14 Pro Max (4,323mAh): ~3.5 charges

Note: Some power is lost during conversion, so actual capacity is approximately 12,000-13,000mAh usable.

Q: How long does it take to charge the power bank itself?
A: With an 18W USB-C charger: approximately 6-7 hours for a full charge. We recommend charging overnight. The LED indicators show charging progress (each LED = 25%).

Q: Can I charge multiple devices simultaneously?
A: Yes! The QuickCharge features:
- 2x USB-A outputs (each up to 12W)
- 1x USB-C port (up to 18W input/output)
You can charge up to 3 devices at once, though this will reduce the total power delivered to each device.

Q: Is it safe to leave devices connected overnight?
A: Yes, the power bank has built-in overcharge protection and will automatically stop charging when your device reaches 100%.

Q: What is QuickCharge technology?
A: QuickCharge 3.0 can charge compatible devices up to 4x faster than standard charging. Your device must support QuickCharge to benefit from the fast charging speeds.

Q: Can I bring this on an airplane?
A: Yes, the 20,000mAh capacity (74Wh) is under the TSA limit of 100Wh for carry-on luggage. However, it must be in your carry-on bag, not checked luggage.

Q: Why is my power bank not charging my device?
A: Check the following:
- Ensure the power bank is charged (press the power button to see LED indicators)
- Try a different charging cable
- Press the power button to activate charging
- Some devices require specific cables (e.g., USB-C to USB-C for newer phones)
- Check if the power bank has entered sleep mode (press power button twice to wake)

Q: How do I know when the power bank needs recharging?
A: Press the power button to check the LED indicators:
- 4 LEDs lit: 75-100% charged
- 3 LEDs lit: 50-75% charged
- 2 LEDs lit: 25-50% charged
- 1 LED lit: Under 25% - recharge soon
- 1 LED blinking: Under 10% - recharge immediately

Q: What safety features does the power bank have?
A: The QuickCharge includes:
- Overcharge protection
- Over-discharge protection
- Short circuit protection
- Temperature protection
- Surge protection
- Foreign object detection

Q: Can I use my phone while it's charging from the power bank?
A: Yes, absolutely! You can use your phone normally while charging. However, using power-intensive apps may slow down the charging speed.

Q: What is pass-through charging?
A: Pass-through charging allows you to charge your devices while the power bank itself is being charged. However, we recommend avoiding this when possible as it may reduce the power bank''s lifespan over time.',
 'faq', '2024-09-18 13:00:00', 'Customer Support Team'),

('DOC-008', 'ALL', 'policy', 'Return and Warranty Policy',
 'RETURN AND WARRANTY POLICY

RETURN POLICY:
We offer a 30-day return policy on all products purchased from our store.

ELIGIBILITY:
- Product must be in original condition with all accessories
- Original packaging should be included when possible
- Product must not show signs of damage or excessive wear
- Proof of purchase (receipt or order number) required

RETURN PROCESS:
1. Contact customer support within 30 days of delivery
2. Provide order number and reason for return
3. Receive return authorization and shipping label
4. Package item securely and ship within 7 days
5. Refund processed within 5-7 business days of receiving return

RETURN SHIPPING:
- Free return shipping for defective products
- Customer pays return shipping for change of mind returns
- We recommend using tracked shipping service

WARRANTY COVERAGE:
All products include a 1-year manufacturer warranty covering:
- Manufacturing defects
- Material defects
- Workmanship issues

NOT COVERED:
- Physical damage from drops or impacts
- Water damage (unless product is water-resistant and damage occurred within spec)
- Normal wear and tear
- Unauthorized repairs or modifications
- Lost or stolen items

WARRANTY CLAIM PROCESS:
1. Contact customer support with order number
2. Describe the issue in detail and provide photos if possible
3. Support team will diagnose the issue
4. If approved, receive prepaid shipping label
5. Replacement or repair typically completed within 10-14 business days

EXTENDED WARRANTY:
Extended warranty options available at purchase:
- 2-year extended warranty: Adds 1 additional year
- 3-year extended warranty: Adds 2 additional years
- Accidental damage protection: Covers drops and spills

INTERNATIONAL ORDERS:
- Same return policy applies
- Customer responsible for return shipping costs
- Customs fees are non-refundable
- Warranty honored worldwide

For warranty or return questions, contact: support@techstore.com or call 1-800-TECH-HELP',
 'policy', '2024-08-01 10:00:00', 'Legal Team'),

('DOC-009', 'PROD-101', 'troubleshooting', 'UltraSound Pro - Audio Issues',
 'TROUBLESHOOTING AUDIO PROBLEMS

SOUND QUALITY ISSUES:

AUDIO CUTTING OUT OR STUTTERING:
- Ensure device is within 30 feet of your headphones
- Remove obstacles between headphones and device
- Turn off other Bluetooth devices nearby
- Disable Wi-Fi temporarily to test for interference
- Update Bluetooth drivers on your computer
- Reset the headphones (hold power + volume up for 10 seconds)

LOW VOLUME:
- Check volume on both headphones and connected device
- Disable volume limiting features on your device
- Ensure earcups are properly sealed around your ears
- Clean the mesh covers on the speakers
- Try different audio source or app
- Check if sound is balanced (not shifted to one side)

SOUND ONLY IN ONE EAR:
- Check audio balance settings on your device
- Try different audio source to isolate the issue
- Inspect headphone cable (if using wired mode)
- Clean the headphone jack and connectors
- Reset headphones to factory settings
- Contact support if issue persists (may be hardware defect)

POOR BASS RESPONSE:
- Ensure proper seal between earcups and ears
- Disable any equalizer settings that reduce bass
- Try different ear cushion positions
- Check if ANC is enabled (slight bass boost when on)
- Test with bass-heavy music to confirm

MICROPHONE ISSUES:

PEOPLE CAN'T HEAR YOU:
- Ensure microphone is not muted (check LED indicator)
- Position microphone closer to your mouth
- Reduce background noise
- Test microphone on different device
- Check app permissions for microphone access
- Clean microphone opening gently

MICROPHONE SOUNDS MUFFLED:
- Check for debris blocking the microphone
- Disable wind noise reduction in settings
- Update firmware to latest version
- Test in different environment
- Verify microphone is selected as input device in system settings

ECHO DURING CALLS:
- Reduce headphone volume
- Move away from walls or hard surfaces
- Disable speaker on the other end
- Enable echo cancellation in your calling app
- Ensure both parties are not using speakerphone

CONNECTIVITY ISSUES:

WON'T PAIR WITH DEVICE:
- Ensure headphones are in pairing mode (LED flashing blue)
- Delete previous pairing from device and try again
- Reset headphones to factory settings
- Ensure headphones are charged
- Turn Bluetooth off and on again on your device
- Try pairing with different device to isolate issue

KEEPS DISCONNECTING:
- Ensure battery is sufficiently charged
- Update device firmware/OS
- Forget and re-pair the connection
- Disable battery optimization for Bluetooth
- Check for interference from other wireless devices
- Stay within recommended range (30 feet)',
 'troubleshooting', '2024-09-20 15:00:00', 'Technical Support Team'),

('DOC-010', 'PROD-103', 'specifications', 'PowerBook Elite - Technical Specifications',
 'POWERBOOK ELITE - DETAILED SPECIFICATIONS

PROCESSOR:
- Intel Core i7-1165G7 (11th Generation)
- Base Clock Speed: 2.8 GHz
- Turbo Boost up to 4.7 GHz
- 4 Cores / 8 Threads
- 12 MB Intel Smart Cache
- 28W TDP

MEMORY:
- 16GB LPDDR4X RAM
- Dual Channel
- 4267 MHz
- Soldered (not upgradeable)

STORAGE:
- 512GB PCIe NVMe SSD
- Read Speed: up to 3,500 MB/s
- Write Speed: up to 3,000 MB/s
- M.2 2280 form factor
- Upgradeable to 2TB

DISPLAY:
- 14-inch IPS LCD
- Resolution: 2560 x 1600 (WQXGA)
- Aspect Ratio: 16:10
- Brightness: 400 nits
- Color Gamut: 100% sRGB
- Refresh Rate: 60Hz
- Anti-glare coating
- Touch: No

GRAPHICS:
- Intel Iris Xe Graphics
- Shared memory with system RAM
- Supports up to 3 external displays
- HDMI 2.0 output
- Thunderbolt 4 (DisplayPort Alt Mode)

BATTERY:
- 60 Wh lithium-polymer battery
- Up to 12 hours typical use
- USB-C charging (65W adapter included)
- Fast charging: 50% in 30 minutes
- Supports USB PD charging

CONNECTIVITY:
Ports:
- 2x Thunderbolt 4 (USB-C)
- 2x USB 3.2 Gen 2 Type-A
- 1x HDMI 2.0
- 1x 3.5mm headphone/microphone combo jack
- 1x SD card reader (UHS-II)

Wireless:
- Wi-Fi 6 (802.11ax)
- Bluetooth 5.1
- Optional: 4G LTE (select models)

KEYBOARD & TRACKPAD:
- Backlit keyboard with adjustable brightness
- 1.3mm key travel
- Precision glass trackpad
- Multi-touch gestures support
- Fingerprint reader integrated in power button

AUDIO:
- Stereo speakers (2W x 2)
- Dual microphone array
- 3.5mm combo jack
- Supports Hi-Res audio

CAMERA:
- 720p HD webcam
- Fixed focus
- Privacy shutter (physical)
- Windows Hello compatible (with infrared camera model)

PHYSICAL DIMENSIONS:
- Width: 12.6 inches (320mm)
- Depth: 8.9 inches (226mm)
- Height: 0.63 inches (16mm)
- Weight: 3.1 lbs (1.4 kg)

BUILD MATERIALS:
- Aluminum chassis
- Magnesium alloy palm rest
- Reinforced glass trackpad

OPERATING SYSTEM:
- Windows 11 Pro (64-bit)
- Downgrade rights to Windows 10 Pro
- Licensed for 1 device

SECURITY:
- TPM 2.0 chip
- Fingerprint reader
- Kensington lock slot
- Firmware-based password protection
- BitLocker support

ENVIRONMENTAL:
- ENERGY STAR certified
- EPEAT Gold registered
- RoHS compliant
- Recyclable packaging

OPERATING CONDITIONS:
- Temperature: 50° to 95°F (10° to 35°C)
- Humidity: 20% to 80% non-condensing
- Altitude: 0 to 10,000 feet

WARRANTY:
- 1-year limited hardware warranty
- 90 days complimentary technical support
- Optional extended warranty available',
 'specifications', '2024-09-25 10:00:00', 'Technical Writing Team');

-- ============================================================================
-- DATASET 4: SALES CALL TRANSCRIPTS
-- For summarization and sentiment analysis
-- ============================================================================

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
 'Jennifer: Good afternoon! This is Jennifer Martinez from TechStore. Am I speaking with Michael Chen from ABC Corporation?

Michael: Yes, that''s me. Thanks for calling.

Jennifer: Thank you for your time today, Michael. I understand you were interested in learning more about our PowerBook Elite laptop for your development team. Is that correct?

Michael: Yes, exactly. We are expanding our development team and need about 15 new laptops. We have been looking at several options and wanted to understand what differentiates your PowerBook Elite from competitors.

Jennifer: Great question. The PowerBook Elite is specifically designed for developers and creative professionals. It features an 11th gen Intel i7 processor, 16GB of RAM, and a 512GB SSD. But what really sets it apart is the build quality and the 14-inch high-resolution display with 100% sRGB color accuracy.

Michael: That sounds promising. Our developers often run multiple virtual machines and Docker containers. Will 16GB be sufficient, or should we be looking at upgrading?

Jennifer: That''s a very valid concern. For your use case with VMs and containers, I would actually recommend considering our PowerBook Elite Pro model, which comes with 32GB RAM. It''s about $400 more per unit, but for your workflow, it would provide much better performance and reduce frustration for your team.

Michael: I appreciate the honest recommendation. What about the warranty and support? If a laptop fails, how quickly can we get it repaired or replaced?

Jennifer: We offer a standard 1-year warranty with next-business-day replacement for defective units. For corporate customers, we also offer a 3-year extended warranty with on-site service for an additional fee. Given that you are purchasing 15 units, I can offer you a 15% discount on the extended warranty package.

Michael: That''s quite helpful. Let me discuss this with my team and get back to you. Can you send me a detailed quote for both configurations - the standard Elite and the Elite Pro, both with the 3-year warranty?

Jennifer: Absolutely! I will send that over within the hour. I will also include some case studies from other development teams who have deployed our laptops. Is there anything else I can help clarify today?

Michael: No, that covers everything for now. Thank you for your time and the detailed information.

Jennifer: My pleasure, Michael. I look forward to hearing from you soon. Have a great day!',
 'proposal_sent', 'PowerBook Elite'),

('CALL-002', 'David Park', 'Smith & Associates', '2024-10-02 10:30:00', 18,
 'David: Hi, this is David Park from TechStore. May I speak with Sarah Johnson?

Sarah: Speaking. What is this regarding?

David: Hi Sarah! I am following up on your inquiry about our SmartCam 4K security cameras. You submitted a form on our website last week asking about pricing for a multi-camera setup.

Sarah: Oh yes, I remember. To be honest, I have already purchased cameras from another vendor. They were significantly cheaper than what I saw on your website.

David: I understand. May I ask which vendor you went with and what features were most important to you?

Sarah: I went with SecureView cameras. They were about half the price of your SmartCam. I mainly needed basic recording and motion detection for our small office.

David: That makes sense. SecureView makes decent budget cameras. The main difference with our SmartCam 4K is the AI-powered detection that can distinguish between people, vehicles, and animals, which significantly reduces false alarms. We also offer cloud storage with end-to-end encryption and much better night vision with our infrared technology.

Sarah: Those features sound nice, but for our needs, the basic cameras work fine. We are a small business and need to watch our budget carefully.

David: I completely understand. Price is definitely important. Well, if you ever need to expand your system or if those cameras do not meet your needs, please keep us in mind. We also offer a trade-in program where we will give you credit toward our cameras even if you bought them elsewhere.

Sarah: Good to know. Thanks for the call.

David: Thank you for your time, Sarah. Have a great day!',
 'lost_to_competitor', 'SmartCam 4K'),

('CALL-003', 'Maria Rodriguez', 'Downtown Fitness Center', '2024-10-03 15:45:00', 41,
 'Maria: Good afternoon! This is Maria Rodriguez from TechStore. Is this Karen Thompson from Downtown Fitness Center?

Karen: Yes, hi Maria. Thanks for calling back.

Maria: Of course! I wanted to follow up on our conversation last week about equipping your fitness center with FitTrack smartwatches for your premium membership program. Have you had a chance to review the proposal I sent over?

Karen: Yes, I have, and I am very interested. The idea of offering our premium members a branded smartwatch as part of their membership is exciting. I discussed it with our management team and they are on board. We would like to move forward with an initial order of 50 watches.

Maria: That is fantastic news, Karen! I am so glad the management team sees the value. The FitTrack watches will integrate seamlessly with your fitness classes, and members will love being able to track their workouts in real-time.

Karen: Exactly. We are particularly interested in the heart rate monitoring and calorie tracking features. Can we customize the watch faces with our gym logo?

Maria: Absolutely! We offer custom branding for corporate orders over 25 units. We can pre-load your gym logo as the default watch face, and members can still customize it if they want. There is no additional charge for this service with your order size.

Karen: Perfect. What is the timeline for delivery once we place the order?

Maria: For an order of 50 units with custom branding, we are looking at approximately 3-4 weeks from order confirmation to delivery. We will send you sample watch faces for approval before we proceed with the full order.

Karen: That works for our timeline. We are launching the new premium membership tier in early November, so 3-4 weeks is perfect. What are the next steps?

Maria: I will send you the final contract this afternoon. Once you review and sign, we will send over the branding questionnaire. Our design team will create mockups for your approval within 3 business days, and then we will move into production. I will be your dedicated account manager throughout the process.

Karen: Excellent. I really appreciate your help with this, Maria. This is going to be a great addition to our gym.

Maria: Thank you so much, Karen! I am excited to work with you on this. You will have the contract within the hour. Please do not hesitate to reach out if you have any questions.

Karen: Will do. Talk soon!',
 'closed_won', 'FitTrack Smart Watch'),

('CALL-004', 'Robert Chen', 'Tech Startup Inc', '2024-10-04 11:00:00', 25,
 'Robert: Hello, this is Robert Chen from TechStore. Am I speaking with Alex Kim?

Alex: Yes, hi Robert.

Robert: Thanks for taking my call, Alex. I am reaching out because I saw that Tech Startup Inc recently raised a Series A round. Congratulations! I wanted to see if you might be interested in upgrading your office technology as you scale your team.

Alex: Thank you. We did just close our funding. What specifically did you have in mind?

Robert: Well, we specialize in outfitting growing tech companies with everything from laptops to security cameras to power banks for mobile teams. I would love to understand your current setup and see where we might be able to help.

Alex: To be honest, Robert, we have pretty good relationships with our current vendors. We have been working with them since we started the company and they have given us good pricing as we have grown.

Robert: I totally understand loyalty to vendors who have supported you from the beginning. That is important. I am not necessarily trying to replace those relationships. However, as you scale from 20 to 50 or 100 employees, your needs often change. We specialize in that growth phase and offer dedicated account management, bulk pricing, and same-day support for the Bay Area.

Alex: That is interesting. We are actually planning to hire about 30 people over the next six months. What kind of pricing could you offer on laptops for new hires?

Robert: For an order of 30 laptops, I could offer you 20-25% off retail, plus free shipping and setup. We also offer a lease-to-own option if you want to preserve capital, which many startups find helpful after raising a round.

Alex: The lease option is intriguing. Can you send me some information on that? No commitment, but I would like to see the numbers.

Robert: Absolutely. I will put together a proposal showing both purchase and lease options for 30 PowerBook Elite laptops, which is our most popular model for startups. I will include a few case studies from similar companies. When would be a good time to follow up after you have had a chance to review?

Alex: Give me about a week. Send the proposal and I will discuss it with our COO. We can schedule a follow-up call after that.

Robert: Perfect. You will have the proposal by end of day today. I will send a calendar invite for next Thursday to check in. Does late morning work for you?

Alex: Yes, that should be fine.

Robert: Great! Thanks for your time, Alex, and again, congratulations on the funding.

Alex: Thanks, Robert. Talk to you next week.',
 'follow_up_scheduled', 'PowerBook Elite');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all tables were created and populated
SELECT 'CUSTOMER_SUPPORT_TICKETS' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_SUPPORT_TICKETS
UNION ALL
SELECT 'PRODUCT_REVIEWS', COUNT(*) FROM PRODUCT_REVIEWS
UNION ALL
SELECT 'PRODUCT_DOCS', COUNT(*) FROM PRODUCT_DOCS
UNION ALL
SELECT 'SALES_TRANSCRIPTS', COUNT(*) FROM SALES_TRANSCRIPTS;

-- Check language distribution in support tickets
SELECT 
  language,
  COUNT(*) AS ticket_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM CUSTOMER_SUPPORT_TICKETS
GROUP BY language
ORDER BY ticket_count DESC;

-- Check rating distribution in reviews
SELECT 
  rating,
  COUNT(*) AS review_count,
  ROUND(AVG(helpful_count), 0) AS avg_helpful_votes
FROM PRODUCT_REVIEWS
GROUP BY rating
ORDER BY rating DESC;

-- Verify document types
SELECT 
  doc_type,
  COUNT(*) AS doc_count
FROM PRODUCT_DOCS
GROUP BY doc_type
ORDER BY doc_count DESC;

-- Check sales call outcomes
SELECT 
  outcome,
  COUNT(*) AS call_count,
  ROUND(AVG(call_duration_minutes), 1) AS avg_duration_minutes
FROM SALES_TRANSCRIPTS
GROUP BY outcome
ORDER BY call_count DESC;

/*******************************************************************************
 * SAMPLE CORTEX QUERIES TO TEST THE DATA
 * Run these to verify Cortex functions work with your data
 *******************************************************************************/

-- Test sentiment analysis on support tickets
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  CASE 
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) > 0.5 THEN 'Positive'
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.5 THEN 'Negative'
    ELSE 'Neutral'
  END AS sentiment_category
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

-- Test translation on non-English tickets
SELECT 
  ticket_id,
  language,
  subject AS original_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en') AS english_subject,
  LEFT(description, 100) AS original_description_preview,
  LEFT(SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en'), 100) AS english_description_preview
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language != 'en'
LIMIT 3;

-- Test summarization on long documents
SELECT 
  doc_id,
  title,
  LENGTH(content) AS original_length,
  SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary,
  LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) AS summary_length
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
LIMIT 2;

-- Test LLM completion for categorization
SELECT 
  ticket_id,
  subject,
  category AS actual_category,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Categorize this customer support ticket into one of these categories: shipping_damage, returns, payment_issue, defective_product, general_inquiry. 
    
    Ticket: ' || subject || '
    
    Category:'
  ) AS suggested_category
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

/*******************************************************************************
 * POST-LOAD CHECKLIST:
 * 
 * □ All 4 tables created successfully
 * □ Row counts match expectations (15+ tickets, 15+ reviews, 10+ docs, 4+ calls)
 * □ Language variety in support tickets (5+ languages)
 * □ Rating variety in reviews (1-5 stars)
 * □ Cortex sentiment function works
 * □ Cortex translate function works
 * □ Cortex summarize function works
 * □ Cortex complete function works
 * □ Data is realistic and relatable
 * □ Ready for lab deployment
 * 
 *******************************************************************************/