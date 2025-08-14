-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- مضيف: 127.0.0.1:3306
-- وقت الجيل: 13 أغسطس 2025 الساعة 21:33
-- إصدار الخادم: 10.11.10-MariaDB-log
-- نسخة PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- قاعدة بيانات: `u990109832_coprra`
--

DELIMITER $$
--
-- الإجراءات
--
CREATE DEFINER=`u990109832_gasser`@`127.0.0.1` PROCEDURE `GenerateAIRecommendations` (IN `p_user_id` BIGINT, IN `p_limit` INT)   BEGIN
    SELECT 
        ar.product_id,
        ar.recommendation_type,
        ar.confidence_score,
        ar.reason
    FROM ai_recommendations ar
    WHERE ar.user_id = p_user_id
    ORDER BY ar.confidence_score DESC
    LIMIT p_limit;
END$$

CREATE DEFINER=`u990109832_gasser`@`127.0.0.1` PROCEDURE `GetConversationContext` (IN `p_user_id` BIGINT, IN `p_limit` INT)   BEGIN
    SELECT 
        c.message,
        c.mode,
        c.intent,
        c.confidence_score,
        c.created_at,
        r.response,
        r.type as response_type
    FROM ai_conversations c
    LEFT JOIN ai_responses r ON c.id = r.conversation_id
    WHERE c.user_id = p_user_id
    ORDER BY c.created_at DESC
    LIMIT p_limit;
END$$

CREATE DEFINER=`u990109832_gasser`@`127.0.0.1` PROCEDURE `LogAIIteraction` (IN `p_user_id` BIGINT, IN `p_session_id` VARCHAR(255), IN `p_message` TEXT, IN `p_language` VARCHAR(10), IN `p_mode` ENUM('general','shopping','support'), IN `p_intent` VARCHAR(100), IN `p_confidence_score` DECIMAL(3,2))   BEGIN
    INSERT INTO ai_conversations (user_id, session_id, message, language, mode, intent, confidence_score)
    VALUES (p_user_id, p_session_id, p_message, p_language, p_mode, p_intent, p_confidence_score);
    
    SELECT LAST_INSERT_ID() as conversation_id;
END$$

CREATE DEFINER=`u990109832_gasser`@`127.0.0.1` PROCEDURE `UpdateUserPreferences` (IN `p_user_id` BIGINT, IN `p_keyword` VARCHAR(255), IN `p_category_id` BIGINT, IN `p_preference_type` ENUM('search','browse','purchase','view'))   BEGIN
    INSERT INTO user_preferences (user_id, keyword, category_id, preference_type, interest_level, last_interaction)
    VALUES (p_user_id, p_keyword, p_category_id, p_preference_type, 1, NOW())
    ON DUPLICATE KEY UPDATE 
        interest_level = interest_level + 1,
        last_interaction = NOW();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- بنية الجدول `ai_affiliate_integration`
--

CREATE TABLE `ai_affiliate_integration` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `affiliate_network` varchar(100) NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `product_name` varchar(500) NOT NULL,
  `product_description` text DEFAULT NULL,
  `product_image_url` varchar(500) DEFAULT NULL,
  `product_url` varchar(500) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `category` varchar(100) DEFAULT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `review_count` int(11) DEFAULT 0,
  `availability` enum('in_stock','out_of_stock','limited') DEFAULT 'in_stock',
  `commission_rate` decimal(5,2) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_affiliate_integration`
--

INSERT INTO `ai_affiliate_integration` (`id`, `affiliate_network`, `product_id`, `product_name`, `product_description`, `product_image_url`, `product_url`, `price`, `currency`, `category`, `brand`, `rating`, `review_count`, `availability`, `commission_rate`, `last_updated`, `created_at`) VALUES
(1, 'Amazon', 'B08N5WRWNW', 'iPhone 13 Pro', 'Latest iPhone with advanced camera system', NULL, 'https://amazon.com/iphone13pro', 999.99, 'USD', 'Smartphones', 'Apple', 4.80, 0, 'in_stock', 4.00, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, 'eBay', 'EBAY-LAPTOP-001', 'Dell XPS 13', 'Premium ultrabook for professionals', NULL, 'https://ebay.com/dell-xps13', 1299.99, 'USD', 'Laptops', 'Dell', 4.60, 0, 'in_stock', 3.50, '2025-08-13 04:14:27', '2025-08-13 04:14:27');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_analytics`
--

CREATE TABLE `ai_analytics` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `metric_name` varchar(100) NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `metric_unit` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `language` varchar(10) DEFAULT 'ar',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_analytics`
--

INSERT INTO `ai_analytics` (`id`, `date`, `metric_name`, `metric_value`, `metric_unit`, `category`, `language`, `metadata`, `created_at`) VALUES
(1, '2025-08-13', 'conversation_success_rate', 94.50, 'percentage', 'chatbot', 'ar', NULL, '2025-08-13 04:14:27'),
(2, '2025-08-13', 'search_correction_rate', 12.30, 'percentage', 'search', 'ar', NULL, '2025-08-13 04:14:27'),
(3, '2025-08-13', 'recommendation_click_rate', 23.70, 'percentage', 'recommendations', 'ar', NULL, '2025-08-13 04:14:27'),
(4, '2025-08-13', 'content_generation_quality', 87.20, 'score', 'content', 'ar', NULL, '2025-08-13 04:14:27'),
(5, '2025-08-13', 'user_satisfaction', 4.60, 'rating', 'overall', 'ar', NULL, '2025-08-13 04:14:27'),
(6, '2025-08-13', 'daily_searches', 6.00, 'count', 'search', 'ar', NULL, '2025-08-13 04:17:16');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_content_generation`
--

CREATE TABLE `ai_content_generation` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `content_type` enum('product_description','review_summary','blog_post','meta_description') NOT NULL,
  `original_content` text DEFAULT NULL,
  `generated_content` text NOT NULL,
  `language` varchar(10) NOT NULL DEFAULT 'ar',
  `target_language` varchar(10) DEFAULT NULL,
  `generation_prompt` text DEFAULT NULL,
  `quality_score` decimal(3,2) DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 0,
  `is_published` tinyint(1) DEFAULT 0,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_content_generation`
--

INSERT INTO `ai_content_generation` (`id`, `user_id`, `content_type`, `original_content`, `generated_content`, `language`, `target_language`, `generation_prompt`, `quality_score`, `is_approved`, `is_published`, `metadata`, `created_at`, `updated_at`) VALUES
(1, 1, 'product_description', NULL, 'هاتف ذكي متطور مع كاميرا عالية الدقة وشاشة عريضة', 'ar', NULL, NULL, 0.88, 0, 0, NULL, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, 2, 'meta_description', NULL, 'أفضل الهواتف الذكية بأفضل الأسعار - مقارنة شاملة', 'ar', NULL, NULL, 0.92, 0, 0, NULL, '2025-08-13 04:14:27', '2025-08-13 04:14:27');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_conversations`
--

CREATE TABLE `ai_conversations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `language` varchar(10) NOT NULL DEFAULT 'ar',
  `mode` enum('general','shopping','support') NOT NULL DEFAULT 'general',
  `intent` varchar(100) DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_conversations`
--

INSERT INTO `ai_conversations` (`id`, `user_id`, `session_id`, `message`, `language`, `mode`, `intent`, `confidence_score`, `created_at`, `updated_at`) VALUES
(1, NULL, 'session_001', 'أريد شراء هاتف ذكي', 'ar', 'shopping', 'purchase', 0.95, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, NULL, 'session_002', 'كيف أقارن بين المنتجات؟', 'ar', 'general', 'help', 0.88, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(3, NULL, 'session_003', 'أحتاج مساعدة في التسجيل', 'ar', 'support', 'support', 0.92, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(4, NULL, 'session_001', 'أريد شراء هاتف ذكي', 'ar', 'shopping', 'purchase', 0.95, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(5, NULL, 'session_002', 'كيف أقارن بين المنتجات؟', 'ar', 'general', 'help', 0.88, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(6, NULL, 'session_003', 'أحتاج مساعدة في التسجيل', 'ar', 'support', 'support', 0.92, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(7, NULL, 'session_001', 'أريد شراء هاتف ذكي', 'ar', 'shopping', 'purchase', 0.95, '2025-08-13 04:17:49', '2025-08-13 04:17:49'),
(8, NULL, 'session_002', 'كيف أقارن بين المنتجات؟', 'ar', 'general', 'help', 0.88, '2025-08-13 04:17:49', '2025-08-13 04:17:49'),
(9, NULL, 'session_003', 'أحتاج مساعدة في التسجيل', 'ar', 'support', 'support', 0.92, '2025-08-13 04:17:49', '2025-08-13 04:17:49');

--
-- القوادح `ai_conversations`
--
DELIMITER $$
CREATE TRIGGER `tr_ai_conversation_preferences` AFTER INSERT ON `ai_conversations` FOR EACH ROW BEGIN
    IF NEW.user_id IS NOT NULL THEN
        INSERT INTO user_preferences (user_id, keyword, preference_type, interest_level, last_interaction)
        VALUES (NEW.user_id, NEW.message, 'search', 1, NOW())
        ON DUPLICATE KEY UPDATE 
            interest_level = interest_level + 1,
            last_interaction = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- بنية الجدول `ai_feedback`
--

CREATE TABLE `ai_feedback` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `feedback` text DEFAULT NULL,
  `feedback_type` enum('helpful','not_helpful','incorrect','spam') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `ai_image_generation`
--

CREATE TABLE `ai_image_generation` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `prompt` text NOT NULL,
  `generated_image_url` varchar(500) NOT NULL,
  `image_type` enum('product','banner','icon','thumbnail') NOT NULL DEFAULT 'product',
  `style` varchar(100) DEFAULT NULL,
  `dimensions` varchar(50) DEFAULT NULL,
  `quality_score` decimal(3,2) DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 0,
  `is_used` tinyint(1) DEFAULT 0,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_image_generation`
--

INSERT INTO `ai_image_generation` (`id`, `user_id`, `product_id`, `prompt`, `generated_image_url`, `image_type`, `style`, `dimensions`, `quality_score`, `is_approved`, `is_used`, `metadata`, `created_at`) VALUES
(1, 1, 1, 'Modern smartphone with high-quality camera', '/ai-generated/smartphone_001.jpg', 'product', NULL, NULL, 0.85, 0, 0, NULL, '2025-08-13 04:14:27'),
(2, 2, 2, 'Professional laptop for business use', '/ai-generated/laptop_001.jpg', 'product', NULL, NULL, 0.90, 0, 0, NULL, '2025-08-13 04:14:27');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_recommendations`
--

CREATE TABLE `ai_recommendations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `recommendation_type` enum('collaborative','content_based','contextual','trending') NOT NULL,
  `confidence_score` decimal(3,2) NOT NULL DEFAULT 0.00,
  `reason` varchar(500) DEFAULT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `is_clicked` tinyint(1) DEFAULT 0,
  `is_purchased` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_recommendations`
--

INSERT INTO `ai_recommendations` (`id`, `user_id`, `session_id`, `product_id`, `recommendation_type`, `confidence_score`, `reason`, `context`, `is_clicked`, `is_purchased`, `created_at`, `expires_at`) VALUES
(1, 1, NULL, 1, 'collaborative', 0.85, 'Based on similar user preferences', NULL, 0, 0, '2025-08-13 04:14:27', NULL),
(2, 1, NULL, 2, 'content_based', 0.78, 'Similar to previously viewed products', NULL, 0, 0, '2025-08-13 04:14:27', NULL),
(3, 2, NULL, 3, 'trending', 0.92, 'Currently popular among users', NULL, 0, 0, '2025-08-13 04:14:27', NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `ai_responses`
--

CREATE TABLE `ai_responses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `response` text NOT NULL,
  `type` enum('ai','human','system') NOT NULL DEFAULT 'ai',
  `response_type` enum('text','suggestion','action','redirect') NOT NULL DEFAULT 'text',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_responses`
--

INSERT INTO `ai_responses` (`id`, `conversation_id`, `response`, `type`, `response_type`, `metadata`, `created_at`) VALUES
(1, 1, 'أهلاً بك! سأساعدك في العثور على أفضل الهواتف الذكية. ما هو ميزانيتك؟', 'ai', 'text', NULL, '2025-08-13 04:14:27'),
(2, 2, 'لمقارنة المنتجات، يمكنك إضافة المنتجات إلى قائمة المقارنة. سأوضح لك كيفية القيام بذلك.', 'ai', 'text', NULL, '2025-08-13 04:14:27'),
(3, 3, 'أهلاً بك في وضع الدعم الفني! سأساعدك في حل مشكلة التسجيل. ما هي المشكلة تحديداً؟', 'ai', 'text', NULL, '2025-08-13 04:14:27'),
(4, 1, 'أهلاً بك! سأساعدك في العثور على أفضل الهواتف الذكية. ما هو ميزانيتك؟', 'ai', 'text', NULL, '2025-08-13 04:17:16'),
(5, 2, 'لمقارنة المنتجات، يمكنك إضافة المنتجات إلى قائمة المقارنة. سأوضح لك كيفية القيام بذلك.', 'ai', 'text', NULL, '2025-08-13 04:17:16'),
(6, 3, 'أهلاً بك في وضع الدعم الفني! سأساعدك في حل مشكلة التسجيل. ما هي المشكلة تحديداً؟', 'ai', 'text', NULL, '2025-08-13 04:17:16'),
(7, 1, 'أهلاً بك! سأساعدك في العثور على أفضل الهواتف الذكية. ما هو ميزانيتك؟', 'ai', 'text', NULL, '2025-08-13 04:17:49'),
(8, 2, 'لمقارنة المنتجات، يمكنك إضافة المنتجات إلى قائمة المقارنة. سأوضح لك كيفية القيام بذلك.', 'ai', 'text', NULL, '2025-08-13 04:17:49'),
(9, 3, 'أهلاً بك في وضع الدعم الفني! سأساعدك في حل مشكلة التسجيل. ما هي المشكلة تحديداً؟', 'ai', 'text', NULL, '2025-08-13 04:17:49');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_seo_optimization`
--

CREATE TABLE `ai_seo_optimization` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `content_id` bigint(20) UNSIGNED DEFAULT NULL,
  `content_type` enum('product','category','blog','page') NOT NULL,
  `original_title` varchar(255) DEFAULT NULL,
  `optimized_title` varchar(255) NOT NULL,
  `original_description` text DEFAULT NULL,
  `optimized_description` text NOT NULL,
  `keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`keywords`)),
  `seo_score` decimal(3,2) DEFAULT NULL,
  `suggestions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`suggestions`)),
  `is_applied` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_seo_optimization`
--

INSERT INTO `ai_seo_optimization` (`id`, `user_id`, `content_id`, `content_type`, `original_title`, `optimized_title`, `original_description`, `optimized_description`, `keywords`, `seo_score`, `suggestions`, `is_applied`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 'product', NULL, 'أفضل هاتف ذكي 2024 - مواصفات عالية وسعر ممتاز', NULL, 'اكتشف أفضل الهواتف الذكية لعام 2024 مع مواصفات متطورة وأسعار منافسة. مقارنة شاملة ومراجعات العملاء.', NULL, 0.89, NULL, 0, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, 2, NULL, 'category', NULL, 'هواتف ذكية - أحدث الموديلات وأفضل الأسعار', NULL, 'تصفح مجموعة واسعة من الهواتف الذكية بأحدث التقنيات وأفضل الأسعار. مقارنة شاملة ومراجعات العملاء.', NULL, 0.91, NULL, 0, '2025-08-13 04:14:27', '2025-08-13 04:14:27');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_shopping_assistant`
--

CREATE TABLE `ai_shopping_assistant` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `query` text NOT NULL,
  `budget_range` varchar(100) DEFAULT NULL,
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  `recommended_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recommended_products`)),
  `interaction_count` int(11) DEFAULT 1,
  `is_completed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `ai_shopping_assistant`
--

INSERT INTO `ai_shopping_assistant` (`id`, `user_id`, `session_id`, `query`, `budget_range`, `preferences`, `recommended_products`, `interaction_count`, `is_completed`, `created_at`, `updated_at`) VALUES
(1, NULL, 'session_004', 'أريد هاتف ذكي بمواصفات عالية', '500-1000', '{\"camera\": \"high\", \"battery\": \"long\", \"storage\": \"large\"}', NULL, 1, 0, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, NULL, 'session_005', 'أحتاج لابتوب للعمل', '1000-2000', '{\"performance\": \"high\", \"portability\": \"medium\", \"battery\": \"long\"}', NULL, 1, 0, '2025-08-13 04:14:27', '2025-08-13 04:14:27');

-- --------------------------------------------------------

--
-- بنية الجدول `articles`
--

CREATE TABLE `articles` (
  `id` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `title_en` varchar(255) NOT NULL,
  `title_ar` varchar(255) NOT NULL,
  `content_en` longtext DEFAULT NULL,
  `content_ar` longtext DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `excerpt_ar` text DEFAULT NULL,
  `excerpt_en` text DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `articles`
--

INSERT INTO `articles` (`id`, `slug`, `title_en`, `title_ar`, `content_en`, `content_ar`, `image_url`, `created_at`, `updated_at`, `excerpt_ar`, `excerpt_en`, `category`, `tags`, `author`, `is_published`) VALUES
(1, 'best-smartphones-2024', 'Best Smartphones of 2024', 'أفضل الهواتف الذكية لعام 2024', '<p>As we move through 2024, the smartphone market continues to evolve with exciting new features and improvements. Here are our top picks for the best smartphones this year.</p><h2>Premium Flagship Phones</h2><p>The Samsung Galaxy S24 Ultra and iPhone 15 Pro Max lead the pack with their advanced cameras, powerful processors, and premium build quality.</p>', '<p>مع تقدمنا خلال عام 2024، يستمر سوق الهواتف الذكية في التطور مع ميزات وتحسينات جديدة ومثيرة. إليكم أفضل اختياراتنا للهواتف الذكية هذا العام.</p><h2>الهواتف الرائدة المتميزة</h2><p>يتصدر سامسونج جالاكسي S24 الترا وآيفون 15 برو ماكس المجموعة بكاميراتهما المتقدمة ومعالجاتهما القوية وجودة البناء المتميزة.</p>', 'https://example.com/images/best-smartphones-2024.jpg', '2025-08-10 09:56:23', '2025-08-10 09:56:23', NULL, NULL, NULL, NULL, NULL, 1),
(2, 'tv-buying-guide-2024', 'TV Buying Guide 2024', 'دليل شراء التلفزيون 2024', '<p>Choosing the right TV can be overwhelming with so many options available. This comprehensive guide will help you make the best decision for your needs and budget.</p><h2>Display Technology</h2><p>OLED, QLED, and LED - understanding the differences between these technologies is crucial for making an informed purchase.</p>', '<p>قد يكون اختيار التلفزيون المناسب أمرًا صعبًا مع وجود العديد من الخيارات المتاحة. سيساعدك هذا الدليل الشامل على اتخاذ أفضل قرار يناسب احتياجاتك وميزانيتك.</p><h2>تقنية العرض</h2><p>أوليد وكيو ليد وليد - فهم الاختلافات بين هذه التقنيات أمر بالغ الأهمية لاتخاذ قرار شراء مدروس.</p>', 'https://example.com/images/tv-buying-guide-2024.jpg', '2025-08-10 09:56:23', '2025-08-10 09:56:23', NULL, NULL, NULL, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- بنية الجدول `brands`
--

CREATE TABLE `brands` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `logo_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `brands`
--

INSERT INTO `brands` (`id`, `name`, `slug`, `logo_url`) VALUES
(1, 'Samsung', 'samsung', 'https://example.com/logos/samsung.png'),
(2, 'Apple', 'apple', 'https://example.com/logos/apple.png'),
(3, 'LG', 'lg', 'https://example.com/logos/lg.png'),
(4, 'Sony', 'sony', 'https://example.com/logos/sony.png'),
(5, 'Huawei', 'huawei', 'https://example.com/logos/huawei.png'),
(6, 'Xiaomi', 'xiaomi', 'https://example.com/logos/xiaomi.png'),
(7, 'Dell', 'dell', 'https://example.com/logos/dell.png'),
(8, 'HP', 'hp', 'https://example.com/logos/hp.png'),
(9, 'Lenovo', 'lenovo', 'https://example.com/logos/lenovo.png'),
(10, 'Asus', 'asus', 'https://example.com/logos/asus.png');

-- --------------------------------------------------------

--
-- بنية الجدول `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `parent_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `categories`
--

INSERT INTO `categories` (`id`, `name_en`, `name_ar`, `slug`, `parent_id`) VALUES
(1, 'Electronics', 'الإلكترونيات', 'electronics', NULL),
(2, 'Home Appliances', 'الأجهزة المنزلية', 'home-appliances', NULL),
(3, 'Computers & Laptops', 'الكمبيوترات والحاسوب المحمول', 'computers-laptops', NULL),
(4, 'Mobile Phones', 'الهواتف المحمولة', 'mobile-phones', 1),
(5, 'Tablets', 'الأجهزة اللوحية', 'tablets', 1),
(6, 'Televisions', 'أجهزة التلفزيون', 'televisions', 1),
(7, 'Audio & Headphones', 'الصوتيات وسماعات الرأس', 'audio-headphones', 1),
(8, 'Refrigerators', 'الثلاجات', 'refrigerators', 2),
(9, 'Washing Machines', 'غسالات الملابس', 'washing-machines', 2),
(10, 'Air Conditioners', 'مكيفات الهواء', 'air-conditioners', 2),
(11, 'Laptops', 'الحاسوب المحمول', 'laptops', 3),
(12, 'Desktop Computers', 'أجهزة الكمبيوتر المكتبية', 'desktop-computers', 3),
(13, 'Gaming', 'الألعاب', 'gaming', 3);

-- --------------------------------------------------------

--
-- بنية الجدول `currencies`
--

CREATE TABLE `currencies` (
  `id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `symbol` varchar(10) NOT NULL,
  `flag` varchar(10) NOT NULL,
  `country` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `currencies`
--

INSERT INTO `currencies` (`id`, `code`, `name`, `symbol`, `flag`, `country`) VALUES
(1, 'USD', 'US Dollar', '$', '🇺🇸', 'United States'),
(2, 'EUR', 'Euro', '€', '🇪🇺', 'European Union'),
(3, 'GBP', 'British Pound', '£', '🇬🇧', 'United Kingdom'),
(4, 'JPY', 'Japanese Yen', '¥', '🇯🇵', 'Japan'),
(5, 'CNY', 'Chinese Yuan', '¥', '🇨🇳', 'China'),
(6, 'SAR', 'Saudi Riyal', 'ر.س', '🇸🇦', 'Saudi Arabia'),
(7, 'AED', 'UAE Dirham', 'د.إ', '🇦🇪', 'UAE'),
(8, 'EGP', 'Egyptian Pound', 'ج.م', '🇪🇬', 'Egypt'),
(9, 'CAD', 'Canadian Dollar', 'C$', '🇨🇦', 'Canada'),
(10, 'AUD', 'Australian Dollar', 'A$', '🇦🇺', 'Australia'),
(11, 'INR', 'Indian Rupee', '₹', '🇮🇳', 'India'),
(12, 'BRL', 'Brazilian Real', 'R$', '🇧🇷', 'Brazil'),
(13, 'RUB', 'Russian Ruble', '₽', '🇷🇺', 'Russia'),
(14, 'KRW', 'South Korean Won', '₩', '🇰🇷', 'South Korea'),
(15, 'TRY', 'Turkish Lira', '₺', '🇹🇷', 'Turkey');

-- --------------------------------------------------------

--
-- بنية الجدول `languages`
--

CREATE TABLE `languages` (
  `id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `native_name` varchar(50) NOT NULL,
  `flag` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `languages`
--

INSERT INTO `languages` (`id`, `code`, `name`, `native_name`, `flag`) VALUES
(1, 'en', 'English', 'English', '🇺🇸'),
(2, 'zh', 'Chinese', '中文', '🇨🇳'),
(3, 'hi', 'Hindi', 'हिन्दी', '🇮🇳'),
(4, 'es', 'Spanish', 'Español', '🇪🇸'),
(5, 'ar', 'Arabic', 'العربية', '🇸🇦'),
(6, 'pt', 'Portuguese', 'Português', '🇧🇷'),
(7, 'bn', 'Bengali', 'বাংলা', '🇧🇩'),
(8, 'ru', 'Russian', 'Русский', '🇷🇺'),
(9, 'ja', 'Japanese', '日本語', '🇯🇵'),
(10, 'fr', 'French', 'Français', '🇫🇷'),
(11, 'de', 'German', 'Deutsch', '🇩🇪'),
(12, 'ko', 'Korean', '한국어', '🇰🇷'),
(13, 'tr', 'Turkish', 'Türkçe', '🇹🇷'),
(14, 'it', 'Italian', 'Italiano', '🇮🇹'),
(15, 'vi', 'Vietnamese', 'Tiếng Việt', '🇻🇳');

-- --------------------------------------------------------

--
-- بنية الجدول `pages`
--

CREATE TABLE `pages` (
  `id` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `title_en` varchar(255) NOT NULL,
  `title_ar` varchar(255) NOT NULL,
  `content_en` longtext DEFAULT NULL,
  `content_ar` longtext DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `meta_title_ar` varchar(255) DEFAULT NULL,
  `meta_title_en` varchar(255) DEFAULT NULL,
  `meta_description_ar` text DEFAULT NULL,
  `meta_description_en` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `pages`
--

INSERT INTO `pages` (`id`, `slug`, `title_en`, `title_ar`, `content_en`, `content_ar`, `updated_at`, `meta_title_ar`, `meta_title_en`, `meta_description_ar`, `meta_description_en`, `is_active`, `created_at`) VALUES
(11, 'privacy-policy', 'Privacy Policy', 'سياسة الخصوصية', '<h1>Privacy Policy</h1>\n<p>This privacy policy explains how we collect, use, and protect your personal information when you use our website.</p>\n<h2>Information We Collect</h2>\n<p>We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.</p>\n<h2>How We Use Your Information</h2>\n<p>We use the collected information to provide and improve our services, and send notifications about offers and updates.</p>\n<h2>Data Protection</h2>\n<p>We implement advanced security measures to protect your personal information, including encryption and continuous monitoring.</p>', '<h1>سياسة الخصوصية</h1>\n<p>تشرح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك الشخصية عند استخدام موقعنا الإلكتروني.</p>\n<h2>المعلومات التي نجمعها</h2>\n<p>نجمع المعلومات التي تقدمها لنا مباشرة، مثل عندما تنشئ حسابًا أو تقوم بعملية شراء أو تتصل بنا للحصول على الدعم.</p>\n<h2>كيف نستخدم معلوماتك</h2>\n<p>نستخدم المعلومات المجمعة لتقديم خدماتنا وتحسينها، وإرسال إشعارات حول العروض والتحديثات.</p>\n<h2>حماية البيانات</h2>\n<p>نتخذ تدابير أمنية متقدمة لحماية معلوماتك الشخصية، بما في ذلك التشفير والمراقبة المستمرة.</p>', '2025-08-10 10:20:18', 'سياسة الخصوصية - CopRRA', 'Privacy Policy - CopRRA', 'تعرف على كيفية حماية خصوصيتك وبياناتك الشخصية في موقع CopRRA', 'Learn how we protect your privacy and personal data at CopRRA', 1, '2025-08-10 10:20:18'),
(12, 'terms-of-service', 'Terms of Service', 'شروط الاستخدام', '<h1>Terms of Service</h1>\n<p>Welcome to CopRRA, the leading price comparison platform. By using our website and services, you agree to comply with these terms of use.</p>\n<h2>Acceptance of Terms</h2>\n<p>By using the CopRRA website, you confirm that you are 18 years of age or older and have the legal capacity to enter into this agreement.</p>\n<h2>Service Description</h2>\n<p>CopRRA provides price comparison services for products from different stores, and displays product information and reviews.</p>\n<h2>User Responsibilities</h2>\n<p>As a user of our services, you agree to provide accurate information and maintain the confidentiality of your account data.</p>', '<h1>شروط الاستخدام</h1>\n<p>مرحباً بك في CopRRA، منصة مقارنة الأسعار الرائدة. باستخدامك لموقعنا وخدماتنا، فإنك توافق على الالتزام بشروط الاستخدام هذه.</p>\n<h2>قبول الشروط</h2>\n<p>باستخدام موقع CopRRA، فإنك تؤكد أنك تبلغ من العمر 18 عاماً أو أكثر وتمتلك الأهلية القانونية لإبرام هذه الاتفاقية.</p>\n<h2>وصف الخدمات</h2>\n<p>تقدم CopRRA خدمات مقارنة أسعار المنتجات من متاجر مختلفة، وعرض معلومات المنتجات والمراجعات.</p>\n<h2>مسؤوليات المستخدم</h2>\n<p>كمستخدم لخدماتنا، فإنك توافق على تقديم معلومات دقيقة والحفاظ على سرية بيانات حسابك.</p>', '2025-08-10 10:20:18', 'شروط الاستخدام - CopRRA', 'Terms of Service - CopRRA', 'اقرأ شروط استخدام موقع CopRRA لمقارنة الأسعار', 'Read the terms of use for CopRRA price comparison website', 1, '2025-08-10 10:20:18'),
(13, 'about-us', 'About Us', 'من نحن', '<h1>About Us</h1>\n<p>CopRRA is the leading price comparison platform in the region, aimed at helping consumers find the best prices for the products they need.</p>\n<h2>Our Vision</h2>\n<p>To be the first price comparison platform in the region, and help consumers make informed purchasing decisions.</p>\n<h2>Our Mission</h2>\n<p>Provide comprehensive and accurate price comparison service, with useful product information to help customers make optimal choices.</p>\n<h2>Our Values</h2>\n<ul>\n<li>Transparency in displaying prices and information</li>\n<li>Accuracy in provided data</li>\n<li>Ease of use</li>\n<li>Excellent customer service</li>\n</ul>', '<h1>من نحن</h1>\n<p>CopRRA هي منصة مقارنة الأسعار الرائدة في المنطقة، تهدف إلى مساعدة المستهلكين في العثور على أفضل الأسعار للمنتجات التي يحتاجونها.</p>\n<h2>رؤيتنا</h2>\n<p>أن نكون المنصة الأولى لمقارنة الأسعار في المنطقة، ونساعد المستهلكين في اتخاذ قرارات شراء مدروسة.</p>\n<h2>مهمتنا</h2>\n<p>تقديم خدمة مقارنة أسعار شاملة ودقيقة، مع توفير معلومات مفيدة حول المنتجات لمساعدة العملاء في الاختيار الأمثل.</p>\n<h2>قيمنا</h2>\n<ul>\n<li>الشفافية في عرض الأسعار والمعلومات</li>\n<li>الدقة في البيانات المقدمة</li>\n<li>سهولة الاستخدام</li>\n<li>خدمة العملاء المتميزة</li>\n</ul>', '2025-08-10 10:20:18', 'من نحن - CopRRA', 'About Us - CopRRA', 'تعرف على CopRRA ورؤيتنا في مقارنة الأسعار', 'Learn about CopRRA and our vision in price comparison', 1, '2025-08-10 10:20:18'),
(14, 'contact-us', 'Contact Us', 'اتصل بنا', '<h1>Contact Us</h1>\n<p>We are here to help you! Do not hesitate to contact us for any inquiries or suggestions.</p>\n<h2>Contact Information</h2>\n<p><strong>Email:</strong> info@coprra.com</p>\n<p><strong>Phone:</strong> +966 11 123 4567</p>\n<p><strong>Address:</strong> Riyadh, Saudi Arabia</p>\n<h2>Working Hours</h2>\n<p>Sunday - Thursday: 9:00 AM - 6:00 PM</p>\n<p>Friday - Saturday: Closed</p>\n<h2>Technical Support</h2>\n<p>For technical support, please email us at: support@coprra.com</p>', '<h1>اتصل بنا</h1>\n<p>نحن هنا لمساعدتك! لا تتردد في التواصل معنا لأي استفسارات أو اقتراحات.</p>\n<h2>معلومات الاتصال</h2>\n<p><strong>البريد الإلكتروني:</strong> info@coprra.com</p>\n<p><strong>الهاتف:</strong> +966 11 123 4567</p>\n<p><strong>العنوان:</strong> الرياض، المملكة العربية السعودية</p>\n<h2>ساعات العمل</h2>\n<p>الأحد - الخميس: 9:00 صباحاً - 6:00 مساءً</p>\n<p>الجمعة - السبت: مغلق</p>\n<h2>الدعم الفني</h2>\n<p>للدعم الفني، يرجى مراسلتنا على: support@coprra.com</p>', '2025-08-10 10:20:18', 'اتصل بنا - CopRRA', 'Contact Us - CopRRA', 'تواصل مع فريق CopRRA للاستفسارات والدعم', 'Contact CopRRA team for inquiries and support', 1, '2025-08-10 10:20:18'),
(15, 'faq', 'FAQ', 'الأسئلة الشائعة', '<h1>Frequently Asked Questions</h1>\n<h2>What is CopRRA?</h2>\n<p>CopRRA is a price comparison website that helps users find the best prices across multiple stores.</p>\n<h2>How does CopRRA work?</h2>\n<p>We gather product data from various sources and display them in an easy-to-compare format.</p>\n<h2>Is CopRRA free to use?</h2>\n<p>Yes, CopRRA is completely free for consumers to use.</p>\n<h2>How often are prices updated?</h2>\n<p>We update prices regularly to ensure you get the most current information available.</p>\n<h2>Can I purchase directly through CopRRA?</h2>\n<p>No, we redirect you to the retailer\'s website where you can complete your purchase.</p>', '<h1>الأسئلة الشائعة</h1>\n<h2>ما هو CopRRA؟</h2>\n<p>CopRRA هو موقع لمقارنة الأسعار يساعد المستخدمين في العثور على أفضل الأسعار عبر متاجر متعددة.</p>\n<h2>كيف يعمل CopRRA؟</h2>\n<p>نجمع بيانات المنتجات من مصادر متعددة ونعرضها بطريقة تسهل المقارنة بينها.</p>\n<h2>هل استخدام CopRRA مجاني؟</h2>\n<p>نعم، CopRRA مجاني تماماً للمستهلكين.</p>\n<h2>كم مرة يتم تحديث الأسعار؟</h2>\n<p>نقوم بتحديث الأسعار بانتظام لضمان حصولك على أحدث المعلومات المتاحة.</p>\n<h2>هل يمكنني الشراء مباشرة من خلال CopRRA؟</h2>\n<p>لا، نقوم بتوجيهك إلى موقع المتجر حيث يمكنك إكمال عملية الشراء.</p>', '2025-08-10 10:20:18', 'الأسئلة الشائعة - CopRRA', 'FAQ - CopRRA', 'تعرف على الأسئلة الشائعة حول استخدام موقع CopRRA', 'Learn the most frequently asked questions about using CopRRA', 1, '2025-08-10 10:20:18');

-- --------------------------------------------------------

--
-- بنية الجدول `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description_en` longtext DEFAULT NULL,
  `description_ar` longtext DEFAULT NULL,
  `main_image_url` varchar(255) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT 'USD',
  `average_rating` decimal(2,1) DEFAULT 0.0,
  `total_reviews` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `products`
--

INSERT INTO `products` (`id`, `name_en`, `name_ar`, `slug`, `description_en`, `description_ar`, `main_image_url`, `category_id`, `brand_id`, `price`, `currency_code`, `average_rating`, `total_reviews`, `created_at`, `updated_at`) VALUES
(1, 'Samsung Galaxy S24', 'سامسونج جالاكسي S24', 'samsung-galaxy-s24', 'The latest flagship smartphone from Samsung with advanced AI features.', 'أحدث هاتف ذكي رائد من سامسونج مع ميزات الذكاء الاصطناعي المتقدمة.', 'https://example.com/images/s24.jpg', 4, 1, 799.00, 'USD', 4.5, 1250, '2025-08-11 06:50:21', '2025-08-11 06:50:21'),
(2, 'iPhone 15 Pro', 'آيفون 15 برو', 'iphone-15-pro', 'Apple\'s most powerful iPhone yet, with a titanium design and A17 Pro chip.', 'أقوى آيفون من آبل حتى الآن، بتصميم من التيتانيوم وشريحة A17 Pro.', 'https://example.com/images/iphone15pro.jpg', 4, 2, 999.00, 'USD', 4.8, 2100, '2025-08-11 06:50:21', '2025-08-11 06:50:21'),
(3, 'MacBook Air M3', 'ماك بوك اير M3', 'macbook-air-m3', 'Thin, light, and super powerful with the Apple M3 chip.', 'نحيف، خفيف، وقوي للغاية مع شريحة Apple M3.', 'https://example.com/images/macbookairm3.jpg', 11, 2, 1199.00, 'USD', 4.7, 890, '2025-08-11 06:50:21', '2025-08-11 06:50:21'),
(4, 'Dell XPS 13', 'ديل XPS 13', 'dell-xps-13', 'A compact and powerful laptop with a stunning display.', 'كمبيوتر محمول مدمج وقوي بشاشة مذهلة.', 'https://example.com/images/dellxps13.jpg', 11, 7, 899.00, 'USD', 4.4, 650, '2025-08-11 06:50:21', '2025-08-11 06:50:21');

-- --------------------------------------------------------

--
-- بنية الجدول `product_images`
--

CREATE TABLE `product_images` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `alt_text_en` varchar(255) DEFAULT NULL,
  `alt_text_ar` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`, `alt_text_en`, `alt_text_ar`) VALUES
(1, 1, 'https://example.com/images/s24_1.jpg', 'Samsung Galaxy S24 front view', 'سامسونج جالاكسي S24 عرض أمامي'),
(2, 1, 'https://example.com/images/s24_2.jpg', 'Samsung Galaxy S24 back view', 'سامسونج جالاكسي S24 عرض خلفي'),
(3, 2, 'https://example.com/images/iphone15pro_1.jpg', 'iPhone 15 Pro front view', 'آيفون 15 برو عرض أمامي'),
(4, 2, 'https://example.com/images/iphone15pro_2.jpg', 'iPhone 15 Pro back view', 'آيفون 15 برو عرض خلفي'),
(5, 3, 'https://example.com/images/macbookairm3_1.jpg', 'MacBook Air M3 open', 'ماك بوك اير M3 مفتوح'),
(6, 4, 'https://example.com/images/dellxps13_1.jpg', 'Dell XPS 13 open', 'ديل XPS 13 مفتوح');

-- --------------------------------------------------------

--
-- بنية الجدول `product_prices`
--

CREATE TABLE `product_prices` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `store_name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `product_url` varchar(2048) NOT NULL,
  `last_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `product_prices`
--

INSERT INTO `product_prices` (`id`, `product_id`, `store_name`, `price`, `currency_code`, `product_url`, `last_updated`) VALUES
(1, 1, 'Amazon', 799.00, 'USD', 'https://www.amazon.com/samsung-galaxy-s24', '2025-08-11 06:50:21'),
(2, 1, 'Best Buy', 819.00, 'USD', 'https://www.bestbuy.com/samsung-galaxy-s24', '2025-08-11 06:50:21'),
(3, 2, 'Apple Store', 999.00, 'USD', 'https://www.apple.com/iphone-15-pro', '2025-08-11 06:50:21'),
(4, 2, 'Verizon', 1029.00, 'USD', 'https://www.verizon.com/iphone-15-pro', '2025-08-11 06:50:21'),
(5, 3, 'Apple Store', 1199.00, 'USD', 'https://www.apple.com/macbook-air-m3', '2025-08-11 06:50:21'),
(6, 3, 'B&H Photo', 1179.00, 'USD', 'https://www.bhphotovideo.com/macbook-air-m3', '2025-08-11 06:50:21'),
(7, 4, 'Dell Official', 899.00, 'USD', 'https://www.dell.com/xps-13', '2025-08-11 06:50:21'),
(8, 4, 'Newegg', 919.00, 'USD', 'https://www.newegg.com/dell-xps-13', '2025-08-11 06:50:21');

-- --------------------------------------------------------

--
-- بنية الجدول `product_qa`
--

CREATE TABLE `product_qa` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `question` text NOT NULL,
  `answer` text DEFAULT NULL,
  `answered_by` int(11) DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 0,
  `helpful_votes` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `answered_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `product_specifications`
--

CREATE TABLE `product_specifications` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `spec_key_en` varchar(255) NOT NULL,
  `spec_key_ar` varchar(255) NOT NULL,
  `spec_value_en` text DEFAULT NULL,
  `spec_value_ar` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `product_specifications`
--

INSERT INTO `product_specifications` (`id`, `product_id`, `spec_key_en`, `spec_key_ar`, `spec_value_en`, `spec_value_ar`) VALUES
(1, 1, 'Display', 'الشاشة', '6.2-inch Dynamic AMOLED 2X', 'شاشة Dynamic AMOLED 2X بحجم 6.2 بوصة'),
(2, 1, 'Processor', 'المعالج', 'Snapdragon 8 Gen 3', 'معالج Snapdragon 8 Gen 3'),
(3, 2, 'Display', 'الشاشة', '6.1-inch Super Retina XDR', 'شاشة Super Retina XDR بحجم 6.1 بوصة'),
(4, 2, 'Processor', 'المعالج', 'A17 Pro chip', 'شريحة A17 Pro'),
(5, 3, 'Processor', 'المعالج', 'Apple M3 chip', 'شريحة Apple M3'),
(6, 3, 'RAM', 'الرام', '8GB Unified Memory', 'ذاكرة موحدة 8 جيجابايت'),
(7, 4, 'Display', 'الشاشة', '13.4-inch FHD+', 'شاشة FHD+ بحجم 13.4 بوصة'),
(8, 4, 'Processor', 'المعالج', 'Intel Core Ultra 7', 'معالج Intel Core Ultra 7');

-- --------------------------------------------------------

--
-- بنية الجدول `search_queries`
--

CREATE TABLE `search_queries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `query` varchar(500) NOT NULL,
  `corrected_query` varchar(500) DEFAULT NULL,
  `language` varchar(10) NOT NULL DEFAULT 'ar',
  `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters`)),
  `result_count` int(11) DEFAULT 0,
  `is_corrected` tinyint(1) DEFAULT 0,
  `search_time_ms` int(11) DEFAULT NULL,
  `clicked_results` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`clicked_results`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `search_queries`
--

INSERT INTO `search_queries` (`id`, `user_id`, `query`, `corrected_query`, `language`, `filters`, `result_count`, `is_corrected`, `search_time_ms`, `clicked_results`, `created_at`, `updated_at`) VALUES
(1, NULL, 'هاتف ذكي', NULL, 'ar', NULL, 15, 0, NULL, NULL, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(2, NULL, 'لابتوب', NULL, 'ar', NULL, 23, 0, NULL, NULL, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(3, NULL, 'سماعات', NULL, 'ar', NULL, 8, 0, NULL, NULL, '2025-08-13 04:14:27', '2025-08-13 04:14:27'),
(4, NULL, 'هاتف ذكي', NULL, 'ar', NULL, 15, 0, NULL, NULL, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(5, NULL, 'لابتوب', NULL, 'ar', NULL, 23, 0, NULL, NULL, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(6, NULL, 'سماعات', NULL, 'ar', NULL, 8, 0, NULL, NULL, '2025-08-13 04:17:16', '2025-08-13 04:17:16'),
(7, NULL, 'هاتف ذكي', NULL, 'ar', NULL, 15, 0, NULL, NULL, '2025-08-13 04:17:49', '2025-08-13 04:17:49'),
(8, NULL, 'لابتوب', NULL, 'ar', NULL, 23, 0, NULL, NULL, '2025-08-13 04:17:49', '2025-08-13 04:17:49'),
(9, NULL, 'سماعات', NULL, 'ar', NULL, 8, 0, NULL, NULL, '2025-08-13 04:17:49', '2025-08-13 04:17:49');

--
-- القوادح `search_queries`
--
DELIMITER $$
CREATE TRIGGER `tr_search_query_analytics` AFTER INSERT ON `search_queries` FOR EACH ROW BEGIN
    INSERT INTO ai_analytics (date, metric_name, metric_value, metric_unit, category)
    VALUES (NEW.created_at, 'daily_searches', 1, 'count', 'search')
    ON DUPLICATE KEY UPDATE 
        metric_value = metric_value + 1;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- بنية الجدول `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'site_name', 'CopRRA', 'اسم الموقع', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(2, 'site_url', 'https://coprra.com', 'رابط الموقع', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(3, 'admin_email', 'admin@coprra.com', 'بريد المدير الإلكتروني', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(4, 'default_language', 'ar', 'اللغة الافتراضية', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(5, 'default_currency', 'USD', 'العملة الافتراضية', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(6, 'max_login_attempts', '5', 'أقصى عدد محاولات تسجيل الدخول', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(7, 'session_timeout', '3600', 'مدة انتهاء الجلسة (بالثواني)', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(8, 'email_verification_required', 'true', 'هل يتطلب تفعيل البريد الإلكتروني', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(9, 'password_min_length', '8', 'أقل طول لكلمة المرور', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(10, 'maintenance_mode', 'false', 'وضع الصيانة', 1, '2025-08-13 04:31:39', '2025-08-13 04:31:39');

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `verified_at` timestamp NULL DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expires` timestamp NULL DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `role` varchar(50) DEFAULT 'user',
  `avatar_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `first_name`, `last_name`, `verification_token`, `email_verified`, `verified_at`, `reset_token`, `reset_token_expires`, `last_login`, `is_active`, `role`, `avatar_url`, `created_at`, `updated_at`) VALUES
(1, 'admin@coprra.com', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxvWBSC8ahk1celaHGw3WvHzgm2', 'Admin', 'User', NULL, 1, NULL, NULL, NULL, NULL, 1, 'admin', NULL, '2025-08-13 04:22:59', '2025-08-13 04:22:59'),
(2, 'user@coprra.com', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxvWBSC8ahk1celaHGw3WvHzgm2', 'Test', 'User', NULL, 1, NULL, NULL, NULL, NULL, 1, 'user', NULL, '2025-08-13 04:22:59', '2025-08-13 04:22:59'),
(3, 'moderator@coprra.com', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxvWBSC8ahk1celaHGw3WvHzgm2', 'Moderator', 'User', NULL, 1, NULL, NULL, NULL, NULL, 1, 'moderator', NULL, '2025-08-13 04:22:59', '2025-08-13 04:22:59');

-- --------------------------------------------------------

--
-- بنية الجدول `user_activity_log`
--

CREATE TABLE `user_activity_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `user_login_attempts`
--

CREATE TABLE `user_login_attempts` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `success` tinyint(1) DEFAULT 0,
  `failure_reason` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `user_notifications`
--

CREATE TABLE `user_notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('price_drop','product_available','review_reply','system','promotion') NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `user_notifications`
--

INSERT INTO `user_notifications` (`id`, `user_id`, `type`, `title`, `message`, `data`, `is_read`, `created_at`, `read_at`) VALUES
(1, 2, 'price_drop', 'انخفاض في السعر', 'انخفض سعر المنتج الذي تتابعه بنسبة 15%!', NULL, 0, '2025-08-13 04:31:39', NULL),
(2, 2, 'system', 'مرحباً بك في CopRRA', 'مرحباً بك في موقع CopRRA لمقارنة الأسعار.', NULL, 1, '2025-08-13 04:31:39', NULL),
(3, 3, 'product_available', 'المنتج متوفر الآن', 'المنتج الذي كنت تنتظره أصبح متوفراً الآن.', NULL, 0, '2025-08-13 04:31:39', NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `preference_key` varchar(100) NOT NULL,
  `preference_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `user_preferences`
--

INSERT INTO `user_preferences` (`id`, `user_id`, `preference_key`, `preference_value`, `created_at`, `updated_at`) VALUES
(1, 1, 'language', 'ar', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(2, 1, 'currency', 'USD', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(3, 1, 'theme', 'light', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(4, 1, 'notifications_email', 'true', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(5, 1, 'notifications_price_alerts', 'true', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(6, 2, 'language', 'en', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(7, 2, 'currency', 'USD', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(8, 2, 'theme', 'dark', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(9, 2, 'notifications_email', 'true', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(10, 2, 'notifications_price_alerts', 'true', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(11, 3, 'language', 'ar', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(12, 3, 'currency', 'SAR', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(13, 3, 'theme', 'light', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(14, 3, 'notifications_email', 'true', '2025-08-13 04:31:39', '2025-08-13 04:31:39'),
(15, 3, 'notifications_price_alerts', 'false', '2025-08-13 04:31:39', '2025-08-13 04:31:39');

-- --------------------------------------------------------

--
-- بنية الجدول `user_price_alerts`
--

CREATE TABLE `user_price_alerts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `target_price` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `user_reviews`
--

CREATE TABLE `user_reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `title` varchar(200) DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `is_verified_purchase` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 0,
  `helpful_votes` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(64) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `user_wishlist`
--

CREATE TABLE `user_wishlist` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_ai_content_generation_quality`
-- (See below for the actual view)
--
CREATE TABLE `v_ai_content_generation_quality` (
`content_type` enum('product_description','review_summary','blog_post','meta_description')
,`language` varchar(10)
,`total_generated` bigint(21)
,`approved_content` bigint(21)
,`published_content` bigint(21)
,`avg_quality_score` decimal(7,6)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_ai_conversation_analytics`
-- (See below for the actual view)
--
CREATE TABLE `v_ai_conversation_analytics` (
`conversation_date` date
,`language` varchar(10)
,`mode` enum('general','shopping','support')
,`intent` varchar(100)
,`conversation_count` bigint(21)
,`avg_confidence` decimal(7,6)
,`unique_users` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_ai_recommendation_performance`
-- (See below for the actual view)
--
CREATE TABLE `v_ai_recommendation_performance` (
`recommendation_type` enum('collaborative','content_based','contextual','trending')
,`total_recommendations` bigint(21)
,`clicked_recommendations` bigint(21)
,`purchased_recommendations` bigint(21)
,`avg_confidence` decimal(7,6)
,`click_rate` decimal(27,4)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_search_query_analytics`
-- (See below for the actual view)
--
CREATE TABLE `v_search_query_analytics` (
`search_date` date
,`language` varchar(10)
,`total_searches` bigint(21)
,`corrected_searches` bigint(21)
,`avg_results` decimal(14,4)
,`unique_users` bigint(21)
);

-- --------------------------------------------------------

--
-- بنية الجدول `v_user_preference_insights`
--

CREATE ALGORITHM=UNDEFINED DEFINER=`u990109832_gasser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `v_user_preference_insights`  AS SELECT `up`.`keyword` AS `keyword`, `up`.`interest_level` AS `interest_level`, `up`.`preference_type` AS `preference_type`, `up`.`last_interaction` AS `last_interaction` FROM `user_preferences` AS `up` ORDER BY `up`.`interest_level` DESC, `up`.`last_interaction` DESC ;
-- خطأ في قراءة بيانات الجدول u990109832_coprra.v_user_preference_insights: #1064 - You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'FROM `u990109832_coprra`.`v_user_preference_insights`' at line 1

--
-- Indexes for dumped tables
--

--
-- فهارس للجدول `ai_affiliate_integration`
--
ALTER TABLE `ai_affiliate_integration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_affiliate_product` (`affiliate_network`,`product_id`),
  ADD KEY `idx_affiliate_network` (`affiliate_network`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_brand` (`brand`),
  ADD KEY `idx_price` (`price`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_last_updated` (`last_updated`),
  ADD KEY `idx_ai_affiliate_integration_composite` (`affiliate_network`,`category`,`brand`),
  ADD KEY `idx_ai_affiliate_integration_price` (`price`,`rating`,`last_updated`);

--
-- فهارس للجدول `ai_analytics`
--
ALTER TABLE `ai_analytics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_date_metric_category` (`date`,`metric_name`,`category`),
  ADD KEY `idx_date` (`date`),
  ADD KEY `idx_metric_name` (`metric_name`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_language` (`language`),
  ADD KEY `idx_ai_analytics_composite` (`date`,`metric_name`,`category`),
  ADD KEY `idx_ai_analytics_metric` (`metric_name`,`metric_value`,`date`);

--
-- فهارس للجدول `ai_content_generation`
--
ALTER TABLE `ai_content_generation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_content_type` (`content_type`),
  ADD KEY `idx_language` (`language`),
  ADD KEY `idx_is_approved` (`is_approved`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_ai_content_generation_composite` (`user_id`,`content_type`,`language`),
  ADD KEY `idx_ai_content_generation_quality` (`quality_score`,`is_approved`);

--
-- فهارس للجدول `ai_conversations`
--
ALTER TABLE `ai_conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `idx_language` (`language`),
  ADD KEY `idx_mode` (`mode`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_ai_conversations_composite` (`user_id`,`language`,`created_at`),
  ADD KEY `idx_ai_conversations_intent` (`intent`,`confidence_score`);

--
-- فهارس للجدول `ai_feedback`
--
ALTER TABLE `ai_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation_id` (`conversation_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_feedback_type` (`feedback_type`);

--
-- فهارس للجدول `ai_image_generation`
--
ALTER TABLE `ai_image_generation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_image_type` (`image_type`),
  ADD KEY `idx_is_approved` (`is_approved`),
  ADD KEY `idx_ai_image_generation_composite` (`user_id`,`product_id`,`image_type`),
  ADD KEY `idx_ai_image_generation_quality` (`quality_score`,`is_approved`);

--
-- فهارس للجدول `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_recommendation_type` (`recommendation_type`),
  ADD KEY `idx_confidence_score` (`confidence_score`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_ai_recommendations_composite` (`user_id`,`recommendation_type`,`confidence_score`),
  ADD KEY `idx_ai_recommendations_product` (`product_id`,`is_clicked`,`created_at`);

--
-- فهارس للجدول `ai_responses`
--
ALTER TABLE `ai_responses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation_id` (`conversation_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- فهارس للجدول `ai_seo_optimization`
--
ALTER TABLE `ai_seo_optimization`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_content_id` (`content_id`),
  ADD KEY `idx_content_type` (`content_type`),
  ADD KEY `idx_seo_score` (`seo_score`),
  ADD KEY `idx_is_applied` (`is_applied`),
  ADD KEY `idx_ai_seo_optimization_composite` (`user_id`,`content_type`,`seo_score`),
  ADD KEY `idx_ai_seo_optimization_applied` (`is_applied`,`created_at`);

--
-- فهارس للجدول `ai_shopping_assistant`
--
ALTER TABLE `ai_shopping_assistant`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `idx_is_completed` (`is_completed`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_ai_shopping_assistant_composite` (`user_id`,`session_id`,`is_completed`),
  ADD KEY `idx_ai_shopping_assistant_query` (`query`(100),`created_at`);

--
-- فهارس للجدول `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- فهارس للجدول `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- فهارس للجدول `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `parent_id` (`parent_id`);

--
-- فهارس للجدول `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- فهارس للجدول `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- فهارس للجدول `pages`
--
ALTER TABLE `pages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- فهارس للجدول `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `brand_id` (`brand_id`);

--
-- فهارس للجدول `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- فهارس للجدول `product_prices`
--
ALTER TABLE `product_prices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `currency_code` (`currency_code`);

--
-- فهارس للجدول `product_qa`
--
ALTER TABLE `product_qa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_answered_by` (`answered_by`),
  ADD KEY `idx_is_approved` (`is_approved`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- فهارس للجدول `product_specifications`
--
ALTER TABLE `product_specifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- فهارس للجدول `search_queries`
--
ALTER TABLE `search_queries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_query` (`query`(100)),
  ADD KEY `idx_language` (`language`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_is_corrected` (`is_corrected`),
  ADD KEY `idx_search_queries_composite` (`user_id`,`language`,`created_at`),
  ADD KEY `idx_search_queries_analytics` (`result_count`,`is_corrected`,`created_at`);

--
-- فهارس للجدول `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_setting_key` (`setting_key`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- فهارس للجدول `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_email_verified` (`email_verified`),
  ADD KEY `idx_users_created_at` (`created_at`);

--
-- فهارس للجدول `user_activity_log`
--
ALTER TABLE `user_activity_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- فهارس للجدول `user_login_attempts`
--
ALTER TABLE `user_login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_ip_address` (`ip_address`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_success` (`success`);

--
-- فهارس للجدول `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_user_notifications_user_read` (`user_id`,`is_read`);

--
-- فهارس للجدول `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_preference` (`user_id`,`preference_key`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_preference_key` (`preference_key`);

--
-- فهارس للجدول `user_price_alerts`
--
ALTER TABLE `user_price_alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_target_price` (`target_price`);

--
-- فهارس للجدول `user_reviews`
--
ALTER TABLE `user_reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_product_review` (`user_id`,`product_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_is_approved` (`is_approved`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- فهارس للجدول `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_token` (`session_token`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_session_token` (`session_token`),
  ADD KEY `idx_expires_at` (`expires_at`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_user_sessions_user_expires` (`user_id`,`expires_at`);

--
-- فهارس للجدول `user_wishlist`
--
ALTER TABLE `user_wishlist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_product` (`user_id`,`product_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ai_affiliate_integration`
--
ALTER TABLE `ai_affiliate_integration`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ai_analytics`
--
ALTER TABLE `ai_analytics`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `ai_content_generation`
--
ALTER TABLE `ai_content_generation`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ai_conversations`
--
ALTER TABLE `ai_conversations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ai_feedback`
--
ALTER TABLE `ai_feedback`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_image_generation`
--
ALTER TABLE `ai_image_generation`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ai_responses`
--
ALTER TABLE `ai_responses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ai_seo_optimization`
--
ALTER TABLE `ai_seo_optimization`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ai_shopping_assistant`
--
ALTER TABLE `ai_shopping_assistant`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `articles`
--
ALTER TABLE `articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `currencies`
--
ALTER TABLE `currencies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `languages`
--
ALTER TABLE `languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `pages`
--
ALTER TABLE `pages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `product_prices`
--
ALTER TABLE `product_prices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `product_qa`
--
ALTER TABLE `product_qa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_specifications`
--
ALTER TABLE `product_specifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `search_queries`
--
ALTER TABLE `search_queries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_activity_log`
--
ALTER TABLE `user_activity_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_login_attempts`
--
ALTER TABLE `user_login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_notifications`
--
ALTER TABLE `user_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `user_price_alerts`
--
ALTER TABLE `user_price_alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_reviews`
--
ALTER TABLE `user_reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_wishlist`
--
ALTER TABLE `user_wishlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------

--
-- Structure for view `v_ai_content_generation_quality`
--
DROP TABLE IF EXISTS `v_ai_content_generation_quality`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u990109832_gasser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `v_ai_content_generation_quality`  AS SELECT `ai_content_generation`.`content_type` AS `content_type`, `ai_content_generation`.`language` AS `language`, count(0) AS `total_generated`, count(case when `ai_content_generation`.`is_approved` = 1 then 1 end) AS `approved_content`, count(case when `ai_content_generation`.`is_published` = 1 then 1 end) AS `published_content`, avg(`ai_content_generation`.`quality_score`) AS `avg_quality_score` FROM `ai_content_generation` GROUP BY `ai_content_generation`.`content_type`, `ai_content_generation`.`language` ;

-- --------------------------------------------------------

--
-- Structure for view `v_ai_conversation_analytics`
--
DROP TABLE IF EXISTS `v_ai_conversation_analytics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u990109832_gasser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `v_ai_conversation_analytics`  AS SELECT cast(`ai_conversations`.`created_at` as date) AS `conversation_date`, `ai_conversations`.`language` AS `language`, `ai_conversations`.`mode` AS `mode`, `ai_conversations`.`intent` AS `intent`, count(0) AS `conversation_count`, avg(`ai_conversations`.`confidence_score`) AS `avg_confidence`, count(distinct `ai_conversations`.`user_id`) AS `unique_users` FROM `ai_conversations` GROUP BY cast(`ai_conversations`.`created_at` as date), `ai_conversations`.`language`, `ai_conversations`.`mode`, `ai_conversations`.`intent` ;

-- --------------------------------------------------------

--
-- Structure for view `v_ai_recommendation_performance`
--
DROP TABLE IF EXISTS `v_ai_recommendation_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u990109832_gasser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `v_ai_recommendation_performance`  AS SELECT `ar`.`recommendation_type` AS `recommendation_type`, count(0) AS `total_recommendations`, count(case when `ar`.`is_clicked` = 1 then 1 end) AS `clicked_recommendations`, count(case when `ar`.`is_purchased` = 1 then 1 end) AS `purchased_recommendations`, avg(`ar`.`confidence_score`) AS `avg_confidence`, count(case when `ar`.`is_clicked` = 1 then 1 end) / count(0) * 100 AS `click_rate` FROM `ai_recommendations` AS `ar` GROUP BY `ar`.`recommendation_type` ;

-- --------------------------------------------------------

--
-- Structure for view `v_search_query_analytics`
--
DROP TABLE IF EXISTS `v_search_query_analytics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u990109832_gasser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `v_search_query_analytics`  AS SELECT cast(`search_queries`.`created_at` as date) AS `search_date`, `search_queries`.`language` AS `language`, count(0) AS `total_searches`, count(case when `search_queries`.`is_corrected` = 1 then 1 end) AS `corrected_searches`, avg(`search_queries`.`result_count`) AS `avg_results`, count(distinct `search_queries`.`user_id`) AS `unique_users` FROM `search_queries` GROUP BY cast(`search_queries`.`created_at` as date), `search_queries`.`language` ;

--
-- القيود المفروضة على الجداول الملقاة
--

--
-- قيود الجداول `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `product_prices`
--
ALTER TABLE `product_prices`
  ADD CONSTRAINT `product_prices_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_prices_ibfk_2` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`) ON UPDATE CASCADE;

--
-- قيود الجداول `product_qa`
--
ALTER TABLE `product_qa`
  ADD CONSTRAINT `product_qa_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_qa_ibfk_2` FOREIGN KEY (`answered_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `product_specifications`
--
ALTER TABLE `product_specifications`
  ADD CONSTRAINT `product_specifications_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_activity_log`
--
ALTER TABLE `user_activity_log`
  ADD CONSTRAINT `user_activity_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD CONSTRAINT `user_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `user_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_price_alerts`
--
ALTER TABLE `user_price_alerts`
  ADD CONSTRAINT `user_price_alerts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_reviews`
--
ALTER TABLE `user_reviews`
  ADD CONSTRAINT `user_reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `user_wishlist`
--
ALTER TABLE `user_wishlist`
  ADD CONSTRAINT `user_wishlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
