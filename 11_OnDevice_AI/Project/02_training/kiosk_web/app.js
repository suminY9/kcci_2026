/* ═══════════════════════════════════════════════════════════
   KIOSK SIMULATOR – Client-side Application Logic
   ═══════════════════════════════════════════════════════════ */

(() => {
    'use strict';

    let products = [];
    let cart = {};           
    let activeCategory = 'all';
    let searchQuery = '';

    const $ = (sel) => document.querySelector(sel);
    const $$ = (sel) => document.querySelectorAll(sel);

    const dom = {
        productGrid:    $('#productGrid'),
        loadingState:   $('#loadingState'),
        emptyState:     $('#emptyState'),
        cartItems:      $('#cartItems'),
        cartEmpty:      $('#cartEmpty'),
        cartBadge:      $('#cartBadge'),
        totalItems:     $('#totalItems'),
        totalPrice:     $('#totalPrice'),
        btnPay:         $('#btnPay'),
        btnReset:       $('#btnReset'),
        searchInput:    $('#searchInput'),
        searchClear:    $('#searchClear'),
        paymentOverlay: $('#paymentOverlay'),
        payProcessing:  $('#paymentProcessing'),
        paySuccess:     $('#paymentSuccess'),
        payAmount:      $('#paymentAmount'),
        payAmountDone:  $('#paymentAmountDone'),
        headerClock:    $('#headerClock'),
        toastContainer: $('#toastContainer'),
        countAll:       $('#countAll'),
        countSnack:     $('#countSnack'),
        countDrink:     $('#countDrink'),
    };

    function formatWon(amount) {
        return '₩' + amount.toLocaleString('ko-KR');
    }

    function showToast(message, duration = 2000) {
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.innerHTML = message;
        dom.toastContainer.appendChild(toast);
        setTimeout(() => {
            toast.classList.add('out');
            setTimeout(() => toast.remove(), 300);
        }, duration);
    }

    function updateClock() {
        const now = new Date();
        const opts = {
            year: 'numeric', month: '2-digit', day: '2-digit',
            hour: '2-digit', minute: '2-digit', second: '2-digit',
            hour12: false
        };
        dom.headerClock.textContent = now.toLocaleString('ko-KR', opts);
    }
    setInterval(updateClock, 1000);
    updateClock();

    async function fetchProducts() {
        try {
            const res = await fetch('/api/products');
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            products = await res.json();

            dom.countAll.textContent = products.length;
            dom.countSnack.textContent = products.filter(p => p.category === 'snack').length;
            dom.countDrink.textContent = products.filter(p => p.category === 'drink').length;
            dom.loadingState.classList.add('hidden');
            renderProducts();
        } catch (err) {
            console.error('Failed to load products:', err);
            dom.loadingState.innerHTML = `
                <span style="font-size:2rem">⚠️</span>
                <p>상품을 불러오지 못했습니다</p>
                <p style="font-size:0.8rem;color:var(--text-muted)">${err.message}</p>
            `;
        }
    }

    function getFilteredProducts() {
        return products.filter(p => {
            const matchCategory = activeCategory === 'all' || p.category === activeCategory;
            const matchSearch = !searchQuery ||
                p.class_name.toLowerCase().includes(searchQuery.toLowerCase());
            return matchCategory && matchSearch;
        });
    }

    function renderProducts() {
        const filtered = getFilteredProducts();
        dom.productGrid.innerHTML = '';
        if (filtered.length === 0) {
            dom.emptyState.classList.remove('hidden');
            return;
        }
        dom.emptyState.classList.add('hidden');

        const fragment = document.createDocumentFragment();
        filtered.forEach(p => {
            const card = document.createElement('div');
            card.className = 'product-card';
            card.dataset.classId = p.class_id;
            const badgeClass = p.category === 'snack' ? 'snack' : 'drink';
            const badgeLabel = p.category === 'snack' ? '스낵' : '음료';
            const emoji = p.category === 'snack' ? '🍪' : '🥤';

            card.innerHTML = `
                <span class="product-category-badge ${badgeClass}">${badgeLabel}</span>
                <div class="product-image-wrap">
                    ${p.image
                        ? `<img class="product-image" src="${p.image}" alt="${p.class_name}" loading="lazy"
                               onerror="this.parentElement.innerHTML='<div class=\\'product-image-placeholder\\'>${emoji}</div>'">`
                        : `<div class="product-image-placeholder">${emoji}</div>`
                    }
                </div>
                <div class="product-name" title="${p.class_name}">${p.class_name}</div>
                <div class="product-price">${formatWon(p.price)}</div>
            `;
            card.addEventListener('click', () => addToCart(p));
            fragment.appendChild(card);
        });
        dom.productGrid.appendChild(fragment);
    }

    $$('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            $$('.tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            activeCategory = btn.dataset.category;
            renderProducts();
        });
    });

    let searchTimeout;
    dom.searchInput.addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            searchQuery = e.target.value.trim();
            renderProducts();
        }, 200);
    });
    dom.searchClear.addEventListener('click', () => {
        dom.searchInput.value = '';
        searchQuery = '';
        renderProducts();
        dom.searchInput.focus();
    });

    function addToCart(product) {
        const id = product.class_id;
        if (cart[id]) cart[id].qty += 1;
        else cart[id] = { product, qty: 1 };

        const card = dom.productGrid.querySelector(`[data-class-id="${id}"]`);
        if (card) {
            card.classList.remove('adding');
            void card.offsetWidth; 
            card.classList.add('adding');
        }
        showToast(`🛒 <strong>${product.class_name}</strong> 추가됨`);
        renderCart();
    }

    function removeFromCart(classId) {
        const itemEl = dom.cartItems.querySelector(`[data-cart-id="${classId}"]`);
        if (itemEl) {
            itemEl.classList.add('removing');
            setTimeout(() => {
                delete cart[classId];
                renderCart();
            }, 300);
        } else {
            delete cart[classId];
            renderCart();
        }
    }

    function updateQty(classId, delta) {
        if (!cart[classId]) return;
        cart[classId].qty += delta;
        if (cart[classId].qty <= 0) removeFromCart(classId);
        else renderCart();
    }

    function getCartTotal() {
        let items = 0, total = 0;
        Object.values(cart).forEach(({ product, qty }) => {
            items += qty;
            total += product.price * qty;
        });
        return { items, total };
    }

    function renderCart() {
        const entries = Object.entries(cart);
        const { items, total } = getCartTotal();

        dom.cartBadge.textContent = items;
        dom.cartBadge.classList.remove('bounce');
        void dom.cartBadge.offsetWidth;
        dom.cartBadge.classList.add('bounce');
        dom.totalItems.textContent = `${items}개`;
        dom.totalPrice.textContent = formatWon(total);
        dom.btnPay.disabled = items === 0;

        if (items === 0) {
            dom.cartEmpty.classList.add('visible');
            dom.cartItems.innerHTML = '';
        } else {
            dom.cartEmpty.classList.remove('visible');
            let html = '';
            entries.forEach(([id, { product, qty }]) => {
                const itemTotal = product.price * qty;
                const emoji = product.category === 'snack' ? '🍪' : '🥤';
                html += `
                    <div class="cart-item" data-cart-id="${id}">
                        ${product.image
                            ? `<img class="cart-item-img" src="${product.image}" onerror="this.src=''; this.style.display='none'">`
                            : `<div class="cart-item-img" style="display:flex;align-items:center;justify-content:center;font-size:2rem;width:60px;height:60px;background:rgba(0,0,0,0.03);border-radius:8px;">${emoji}</div>`
                        }
                        <div class="cart-item-info" style="flex:1; min-width:0;">
                            <div class="cart-item-name" style="font-weight:600;font-size:1rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${product.class_name}</div>
                            <div class="cart-item-controls" style="display:flex;justify-content:space-between;align-items:center;margin-top:8px;">
                                <div class="cart-item-price" style="color:var(--text-muted);">${formatWon(product.price)}</div>
                                <div class="qty-control" style="display:flex;align-items:center;background:var(--bg-main);border-radius:15px;border:1px solid var(--border);">
                                    <button class="btn-qty" onclick="updateQty(${id}, -1)" style="width:30px;height:30px;border:none;background:none;cursor:pointer;">-</button>
                                    <div class="qty-display" style="width:30px;text-align:center;font-weight:600;">${qty}</div>
                                    <button class="btn-qty" onclick="updateQty(${id}, 1)" style="width:30px;height:30px;border:none;background:none;cursor:pointer;">+</button>
                                </div>
                            </div>
                            <div class="cart-item-total" style="text-align:right; margin-top:5px; font-weight:700; color:var(--accent);">
                                합계: ${formatWon(itemTotal)}
                            </div>
                        </div>
                    </div>
                `;
            });
            dom.cartItems.innerHTML = html;
        }
    }

    window.updateQty = updateQty;
    
    dom.btnReset.addEventListener('click', () => {
        if (Object.keys(cart).length === 0) return;
        if (confirm('장바구니를 모두 비우시겠습니까?')) {
            cart = {};
            renderCart();
            showToast('🗑️ 장바구니가 초기화되었습니다');
        }
    });

    dom.btnPay.addEventListener('click', async () => {
        const { total } = getCartTotal();
        if (total === 0) return;

        dom.paymentOverlay.classList.add('active');
        dom.payProcessing.classList.add('active');
        dom.paySuccess.classList.remove('active');
        
        try {
            const res = await fetch('/api/checkout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            
            setTimeout(() => {
                dom.payProcessing.classList.remove('active');
                dom.paySuccess.classList.add('active');
                dom.payAmount.textContent = formatWon(total);
                dom.payAmountDone.textContent = formatWon(total);
                
                setTimeout(() => {
                    cart = {};
                    renderCart();
                    dom.paymentOverlay.classList.remove('active');
                    if(res.ok) {
                        showToast('🧾 영수증이 출력되었습니다', 3000);
                    } else {
                        showToast('⚠️ 결제 완료 (영수증 출력 실패)', 3000);
                    }
                }, 3000);
            }, 1500);
            
        } catch (err) {
            console.error('Checkout error:', err);
            dom.paymentOverlay.classList.remove('active');
            showToast('❌ 서버 연결 오류', 3000);
        }
    });

    // ── 장바구니 사이즈 조절바 (Resizer) 추가 ──
    const cartSection = document.querySelector('.cart-section');
    if (cartSection) {
        const resizer = document.createElement('div');
        resizer.style.width = '8px';
        resizer.style.cursor = 'col-resize';
        resizer.style.position = 'absolute';
        resizer.style.left = '-4px';
        resizer.style.top = '0';
        resizer.style.bottom = '0';
        resizer.style.zIndex = '100';
        resizer.style.transition = 'background 0.2s';
        
        cartSection.style.position = 'relative'; 
        cartSection.appendChild(resizer);

        let isResizing = false;
        
        resizer.addEventListener('mouseenter', () => resizer.style.background = 'var(--primary)');
        resizer.addEventListener('mouseleave', () => { if(!isResizing) resizer.style.background = 'transparent'; });
        
        resizer.addEventListener('mousedown', (e) => {
            isResizing = true;
            document.body.style.cursor = 'col-resize';
            resizer.style.background = 'var(--primary)';
            // 드래그 중 텍스트 선택 방지
            document.body.style.userSelect = 'none';
        });
        
        document.addEventListener('mousemove', (e) => {
            if (!isResizing) return;
            // 마우스 위치에서 브라우저 오른쪽 끝까지의 거리를 장바구니 너비로 설정
            let newWidth = window.innerWidth - e.clientX;
            if (newWidth < 300) newWidth = 300; // 최소 너비
            if (newWidth > 800) newWidth = 800; // 최대 너비
            cartSection.style.width = `${newWidth}px`;
        });
        
        document.addEventListener('mouseup', () => {
            if (isResizing) {
                isResizing = false;
                document.body.style.cursor = 'default';
                resizer.style.background = 'transparent';
                document.body.style.userSelect = '';
            }
        });
    }

    // ── 실시간 카메라 동기화 (시간 기반 안정화) ──
    let lastSeen = {};
    const REMOVE_DELAY = 3000;  // 3초간 미감지 시 삭제 (YOLO 깜빡임 여유)

    async function pollCamera() {
        try {
            const res = await fetch('/api/detected');
            if (res.ok) {
                const detected = await res.json();
                const now = Date.now();
                let cartChanged = false;

                // 디버그: 서버가 보내주는 데이터 확인 (F12 콘솔에서 확인 가능)
                const detectedKeys = Object.keys(detected);
                const cartKeys = Object.keys(cart);
                if (detectedKeys.length > 0 || cartKeys.length > 0) {
                    console.log(`[카메라] 감지: {${detectedKeys.map(k => k+':'+detected[k]).join(', ')}} | 장바구니: {${cartKeys.join(', ')}}`);
                }

                // 1. 카메라에 보이는 상품 → 즉시 반영
                for (const [cls_id_str, qty] of Object.entries(detected)) {
                    const id = parseInt(cls_id_str);
                    lastSeen[id] = now;
                    
                    const currentQty = cart[id] ? cart[id].qty : 0;
                    if (currentQty !== qty) {
                        const product = products.find(p => p.class_id === id);
                        if (product) {
                            cart[id] = { product, qty: qty };
                            cartChanged = true;
                            if (qty > currentQty) {
                                showToast(`📷 인식: <strong>${product.class_name}</strong> (${qty}개)`);
                            }
                        }
                    }
                }

                // 2. 장바구니 아이템 중 3초 이상 안 보인 것 삭제
                for (const id_str of Object.keys(cart)) {
                    const id = parseInt(id_str);
                    const last = lastSeen[id] || 0;
                    const elapsed = now - last;
                    if (elapsed > REMOVE_DELAY) {
                        const name = cart[id] ? cart[id].product.class_name : '';
                        console.log(`[삭제] ${name} (${(elapsed/1000).toFixed(1)}초 미감지)`);
                        delete cart[id];
                        delete lastSeen[id];
                        cartChanged = true;
                        showToast(`🗑️ <strong>${name}</strong> 제거됨`);
                    }
                }

                if (cartChanged) renderCart();
            }
        } catch (e) {
            // 네트워크 오류 무시
        }
        setTimeout(pollCamera, 500);
    }

    fetchProducts();
    pollCamera();
    
})();
