// ============================================================
// clear.js - Xoá toàn bộ sản phẩm trong collection 'products'
// Chạy: node clear.js
// ============================================================

// ===== CẤU HÌNH FIREBASE =====
const PROJECT_ID = 'fashionstore-1b406';
const API_KEY    = 'AIzaSyB3zvxQLm5MmF1wHgDR4wJOkz_tSC1hLc8';
const BASE_URL   = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
// ==============================

async function listDocuments(collection) {
  const url = `${BASE_URL}/${collection}?key=${API_KEY}&pageSize=300`;
  const res = await fetch(url);
  if (!res.ok) throw new Error((await res.json()).error?.message);
  const data = await res.json();
  return data.documents ?? [];
}

async function deleteDocument(docName) {
  const url = `https://firestore.googleapis.com/v1/${docName}?key=${API_KEY}`;
  const res = await fetch(url, { method: 'DELETE' });
  if (!res.ok && res.status !== 204) {
    throw new Error((await res.json()).error?.message ?? res.statusText);
  }
}

async function main() {
  console.log('🗑️  FashionStore - Xoá dữ liệu Firestore');
  console.log('==========================================');

  const docs = await listDocuments('products');
  if (docs.length === 0) {
    console.log('ℹ️  Collection "products" đã trống.');
    return;
  }

  console.log(`📦 Tìm thấy ${docs.length} documents cần xoá\n`);

  let success = 0;
  for (const doc of docs) {
    const id = doc.name.split('/').pop();
    process.stdout.write(`  Xoá ${id}... `);
    try {
      await deleteDocument(doc.name);
      console.log('✅');
      success++;
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n==========================================`);
  console.log(`✅ Đã xoá ${success}/${docs.length} documents`);
}

main().catch(err => {
  console.error('❌', err);
  process.exit(1);
});
