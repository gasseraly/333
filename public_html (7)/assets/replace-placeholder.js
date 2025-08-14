const fs = require('fs');
const path = require('path');

// مسار مجلد الـ assets
const assetsDir = path.join(__dirname, 'assets');

// اسم الصورة الجديدة
const newImagePath = 'assets/empty.png';

// أي أسماء أو مسارات الصور القديمة التي تريد استبدالها
const oldImagePatterns = [
  /api\/placeholder\/\d+\/\d+/g, // هذا يغطي 120/60 أو 300/300 وغيرها
];

function replaceInFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  oldImagePatterns.forEach(pattern => {
    content = content.replace(pattern, newImagePath);
  });
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`تم تعديل: ${filePath}`);
}

function walkDir(dir) {
  fs.readdirSync(dir).forEach(file => {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      walkDir(fullPath);
    } else if (file.endsWith('.js')) {
      replaceInFile(fullPath);
    }
  });
}

// تشغيل العملية
walkDir(assetsDir);
console.log('تم استبدال جميع مسارات الصور القديمة بالمسار الجديد.');
