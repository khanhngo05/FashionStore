// ============================================================
// seed.js - Import sản phẩm từ products.json lên Firestore
// Chạy: node seed.js
// Node.js 18+ (có sẵn fetch, không cần cài thêm gì)
// ============================================================

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// ===== CẤU HÌNH FIREBASE =====
const PROJECT_ID = 'fashionstore-1b406';
const API_KEY    = 'AIzaSyB3zvxQLm5MmF1wHgDR4wJOkz_tSC1hLc8';
const BASE_URL   = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
// ==============================

/**
 * Chuyển đổi giá trị JS → Firestore Value format
 */
function toFirestoreValue(val) {
  if (val === null || val === undefined) return { nullValue: null };
  if (typeof val === 'boolean')          return { booleanValue: val };
  if (typeof val === 'number') {
    return Number.isInteger(val)
      ? { integerValue: String(val) }
      : { doubleValue: val };
  }
  if (typeof val === 'string')           return { stringValue: val };
  if (Array.isArray(val)) {
    return {
      arrayValue: {
        values: val.map(toFirestoreValue)
      }
    };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(val) };
}

/**
 * Chuyển object JS → Firestore document fields
 */
function toFirestoreDoc(obj) {
  const fields = {};
  for (const [key, value] of Object.entries(obj)) {
    fields[key] = toFirestoreValue(value);
  }
  return { fields };
}

/**
 * Thêm một document vào Firestore collection
 */
async function addDocument(collection, data) {
  const url = `${BASE_URL}/${collection}?key=${API_KEY}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(toFirestoreDoc(data)),
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.error?.message ?? response.statusText);
  }
  return response.json();
}

// ===== MAIN =====
async function main() {
  console.log('🚀 FashionStore - Firebase Seed Tool');
  console.log('=====================================');

  // Đọc file products.json
  const filePath = join(__dirname, 'products.json');
  let products;
  try {
    const raw = readFileSync(filePath, 'utf-8');
    products = JSON.parse(raw);
  } catch (e) {
    console.error('❌ Không đọc được products.json:', e.message);
    process.exit(1);
  }

  // Validate: phải là array
  if (!Array.isArray(products)) {
    console.error('❌ products.json phải là một JSON array [...]');
    process.exit(1);
  }

  console.log(`📦 Tìm thấy ${products.length} sản phẩm cần import\n`);

  let success = 0;
  let failed  = 0;

  for (let i = 0; i < products.length; i++) {
    const product = products[i];
    const name = product.name ?? `Sản phẩm #${i + 1}`;
    process.stdout.write(`  [${i + 1}/${products.length}] ${name}... `);

    try {
      const result = await addDocument('products', product);
      const docId  = result.name?.split('/').pop() ?? '?';
      console.log(`✅ ID: ${docId}`);
      success++;
    } catch (e) {
      console.log(`❌ Lỗi: ${e.message}`);
      failed++;
    }
  }

  console.log('\n=====================================');
  console.log(`✅ Thành công: ${success} sản phẩm`);
  if (failed > 0) {
    console.log(`❌ Thất bại : ${failed} sản phẩm`);
  }
  console.log(`\n🔗 Xem dữ liệu tại:`);
  console.log(`   https://console.firebase.google.com/project/${PROJECT_ID}/firestore`);
}

main().catch(err => {
  console.error('❌ Lỗi không xác định:', err);
  process.exit(1);
});
