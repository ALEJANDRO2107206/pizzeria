const cart = [];
const formatPrice = value => '$' + value.toLocaleString('es-CL');
const panel = document.querySelector('#cart-panel');

const renderCart = () => {
	const items = document.querySelector('#cart-items');
	document.querySelector('#cart-count').textContent = cart.length;
	if (!cart.length) items.innerHTML = '<p style="color:#777268;font-size:13px">Todavía no has agregado pizzas.</p>';
	else items.innerHTML = cart.map(item => `<div class="cart-item"><strong>${item.name}</strong><span>${formatPrice(item.price)}</span></div>`).join('');
	document.querySelector('#cart-total').textContent = formatPrice(cart.reduce((sum, item) => sum + item.price, 0));
};

document.querySelectorAll('.add').forEach(button => button.addEventListener('click', () => {
	cart.push({ name:button.dataset.name, price:Number(button.dataset.price) });
	renderCart();
	panel.classList.add('open');
}));

document.querySelector('#cart-toggle').addEventListener('click', () => panel.classList.toggle('open'));
document.querySelector('#cart-close').addEventListener('click', () => panel.classList.remove('open'));
document.querySelector('#checkout').addEventListener('click', () => alert(cart.length ? '¡Gracias! En breve confirmaremos tu pedido.' : 'Agrega una pizza para continuar.'));

document.querySelectorAll('.filter').forEach(filter => filter.addEventListener('click', () => {
	document.querySelectorAll('.filter').forEach(item => item.classList.remove('active'));
	filter.classList.add('active');
	document.querySelectorAll('.pizza-card').forEach(card => card.classList.toggle('hidden', filter.dataset.filter !== 'all' && card.dataset.category !== filter.dataset.filter));
}));
