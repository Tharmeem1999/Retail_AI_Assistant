const products = [
  { id:"P001", name:"Wireless Headphones",  category:"Electronics",   brand:"Sony",     availability:"In Stock",      stock:25, price:79.99,   features:"Noise cancellation, Bluetooth 5.0, 20-hour battery",              description:"High-quality wireless headphones with immersive sound." },
  { id:"P002", name:"Smart Watch",           category:"Wearables",     brand:"Samsung",  availability:"In Stock",      stock:15, price:149.99,  features:"Heart-rate monitor, GPS, Sleep tracking, Water resistant",         description:"Smartwatch designed for health and fitness tracking." },
  { id:"P003", name:"Bluetooth Speaker",     category:"Electronics",   brand:"JBL",      availability:"In Stock",      stock:30, price:49.99,   features:"Waterproof, Portable, 10-hour battery",                            description:"Compact Bluetooth speaker with powerful sound." },
  { id:"P004", name:"Gaming Laptop",         category:"Computers",     brand:"ASUS",     availability:"Out of Stock",  stock:0,  price:1199.99, features:"RTX graphics, 16GB RAM, 512GB SSD",                                description:"High-performance laptop for gaming and multitasking." },
  { id:"P005", name:"Smartphone",            category:"Mobile Phones", brand:"Apple",    availability:"In Stock",      stock:10, price:899.99,  features:"Advanced camera, USB-C, Face ID",                                  description:"Premium smartphone with advanced features." },
  { id:"P006", name:"Mechanical Keyboard",   category:"Accessories",   brand:"Logitech", availability:"In Stock",      stock:18, price:89.99,   features:"RGB lighting, Mechanical switches, Wireless",                      description:"Comfortable keyboard for gaming and productivity." },
  { id:"P007", name:"Wireless Mouse",        category:"Accessories",   brand:"Logitech", availability:"In Stock",      stock:40, price:29.99,   features:"Ergonomic design, Rechargeable battery",                           description:"Lightweight wireless mouse with smooth tracking." },
  { id:"P008", name:"4K Monitor",            category:"Displays",      brand:"LG",       availability:"Limited Stock", stock:5,  price:299.99,  features:"27-inch display, HDR support, Ultra HD",                           description:"High-resolution monitor suitable for work and entertainment." },
];

const categoryIcons = {
  "Electronics":   "🎧",
  "Wearables":     "⌚",
  "Computers":     "💻",
  "Mobile Phones": "📱",
  "Accessories":   "🖱️",
  "Displays":      "🖥️",
};
