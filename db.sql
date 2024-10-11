CREATE TABLE IF NOT EXISTS user (
	user_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(255) NOT NULL,
   shortcode VARCHAR(100) NOT NULL,
   status VARCHAR(10) DEFAULT 'active' COMMENT 'active, inactive',
   email TEXT,
   contact_no VARCHAR(100),
   username VARCHAR(100),
   password TEXT NOT NULL,
   image TEXT,
   created DATETIME DEFAULT CURRENT_TIMESTAMP,
   modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS basket_type (
    btype_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image TEXT,
    weight DOUBLE(18,2),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_transfer (
    xfer_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    transfer_no VARCHAR(255),
    from_dept VARCHAR(255),
    to_dept VARCHAR(255),
    status VARCHAR(255) DEFAULT 'pending' COMMENT 'pending, done, cancel',
    remark TEXT,
    created_dept VARCHAR(255) DEFAULT 'warehouse' COMMENT 'warehouse, dept',
    authorize_by VARCHAR(255),
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS item (
    item_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    uom VARCHAR(255) NOT NULL DEFAULT 'kg' COMMENT 'kg, ctn',
    tolerance_lesser DOUBLE(18,2),
    tolerance_exceed DOUBLE(18,2),
    image TEXT,
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_in (
    stockin_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stockin_no VARCHAR(255),
    po_no VARCHAR(255),
    supplier_no VARCHAR(255),
    supplier_address TEXT,
    supplier_name VARCHAR(255),
    attachment TEXT,
    remark TEXT,
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_in_sub (
    stockinsub_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stockin_id BIGINT,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    uom VARCHAR(255) NOT NULL DEFAULT 'kg' COMMENT 'kg, ctn',
    uom_unit INT,
    measure DOUBLE(18,2),
    tolerance DOUBLE(18,2),
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stockin_id) REFERENCES stock_in(stockin_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS audit_trail (
    audit_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(255) COMMENT 'add, edit, delete',
    module VARCHAR(255) COMMENT 'item, stockin, basket, stockinsub, depstockin, stockout, stockxfer, stockxfersub, stockadj',
    ref BIGINT,
    detail TEXT,
    operator VARCHAR(255),
    date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_transfer_sub (
    xfersub_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stockin_sub_id BIGINT,
    xfer_id BIGINT,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    uom VARCHAR(255) NOT NULL DEFAULT 'kg' COMMENT 'kg, ctn',
    measure DOUBLE(18,2),
    fulfilled_measure DOUBLE(18,2),
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stockin_sub_id) REFERENCES stock_in_sub(stockinsub_id),
    FOREIGN KEY (xfer_id) REFERENCES stock_transfer(xfer_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS dept_stockin (
    deptstockin_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    xfersub_id BIGINT,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    usable_measure DOUBLE(18,2),
    disposal_measure DOUBLE(18,2),
    usable_uom VARCHAR(100) NOT NULL DEFAULT 'kg' COMMENT 'kg/unit',
    disposal_uom VARCHAR(100) NOT NULL DEFAULT 'kg' COMMENT 'kg/unit',
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (xfersub_id) REFERENCES stock_transfer_sub(xfersub_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS master_stock (
    mstock_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    measure DOUBLE(18,2),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS dept_stock (
    dstock_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    uom_unit INT,
    measure DOUBLE(18,2),
    matched_measure DOUBLE(18,2) DEFAULT 0,
    used_measure DOUBLE(18,2) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS stock_out (
    stockout_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT,
    deptstockin_id BIGINT,
    cart_id BIGINT,
    supplier_no VARCHAR(255),
    measure DOUBLE(18,2),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (deptstockin_id) REFERENCES dept_stockin(deptstockin_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS warehouse_stock (
    wstock_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    uom_unit INT,
    measure DOUBLE(18,2),
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE IF NOT EXISTS stock_adjustment (
    stockadj_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stockadj_no VARCHAR(255),
    wstock_id BIGINT,
    ref VARCHAR(255),
    remark VARCHAR(255),
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (wstock_id) REFERENCES warehouse_stock(wstock_id)
);

CREATE TABLE IF NOT EXISTS warehouse_stock_adjustment (
    wstag_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    wstock_id BIGINT,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    uom_unit INT,
    stock_measure DOUBLE(18,2),
    checked_measure DOUBLE(18,2),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (wstock_id) REFERENCES warehouse_stock(wstock_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);


CREATE TABLE IF NOT EXISTS stock_adj_sub (
    stockadjsub_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stockadj_id BIGINT,
    item_id BIGINT,
    supplier_no VARCHAR(255),
    old_measure DOUBLE(18,2),
    new_measure DOUBLE(18,2),
    uom VARCHAR(255) DEFAULT 'kg' NOT NULL COMMENT 'kg/ctn',
    dept VARCHAR(255) DEFAULT 'warehouse' COMMENT 'warehouse, dept',
    modified_by VARCHAR(255),
    is_delete INT(1) DEFAULT 0,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stockadj_id) REFERENCES stock_adjustment(stockadj_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);