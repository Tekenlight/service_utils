--[[
    This sample program prints a PDF file from random Puchase Order Data
    It illustrates the usage of chrome_pdf tool

    In commandline, run the following
    $ evlua sample_po.lua
]]
local utils = require('service_utils.common.utils');
local date_utils = require('lua_schema.date_utils');
local template = require 'pl.template';
local s_os = require('service_utils.os');
local chrome_pdf = require('service_utils.chrome_pdf');

-- Utility to split array into chunks
local chunk_array = function(array, first_page_size, chunk_size) 
    local chunks = {};
    if (#array <= first_page_size) then
        table.insert(chunks, array);
    else
        table.insert(chunks, utils.table_slice(array, 1, first_page_size));
        for i = first_page_size + 1, #array, chunk_size do
            table.insert(chunks, utils.table_slice(array, i, i + chunk_size -1));
        end
    end
    return chunks;
end

-- Generate a list of 50 items
local generate_items = function (count)
    local items = {};
    for i = 1, count, 1 do
        table.insert(items, {
            description = "Item" .. i,
            quantity = math.floor(math.random() * 10) + 1,
            price = math.floor(math.random() * 100) + 10,
        });
    end
    return items;
end

local po_data = {
  order_number =  'PO-98765',
  date = tostring(date_utils.today(true)),
  customer_name =  'XYZ Corporation',
  items =  generate_items(50),
};
local first_page_size = 28;
local items_per_page = 34;

local my_env = {
    _parent = _G,
    _debug = true,
    items_per_page = items_per_page,
    item_chunks = chunk_array(po_data.items, first_page_size, items_per_page),
    po_data = po_data,
};

local html = [==[
# local page_count;
# local global_index = 0;
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Purchase Order</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #000; padding: 6px; text-align: left; font-size: 12px; }
    .total-row { font-weight: bold; background-color: #f0f0f0; }
    .page-break { page-break-after: always; }
    h1, p { margin: 0 0 5px 0; }
  </style>
</head>
<body>

  <h1>Purchase Order</h1>
  <p><strong>Order Number:</strong> $(po_data.order_number)</p>
  <p><strong>Date:</strong> $(po_data.date)</p>
  <p><strong>Customer:</strong> $(po_data.customer_name)</p>

# for page_index, chunk in ipairs(item_chunks) do
#    local tablex = require('pl.tablex');
#    local page_sub_total = tablex.reduce(function(sum, item) return sum + (item.quantity * item.price); end, chunk, 0);
#    local is_last_page = (page_index == #item_chunks);
     <table>
       <thead>
         <tr>
           <th>#</th>
           <th>Description</th>
           <th>Quantity</th>
           <th>Price</th>
           <th>Line Total</th>
         </tr>
       </thead>
       <tbody>
# for idx, item in ipairs(chunk) do
# global_index = global_index + 1;
           <tr>
             <td>$(global_index)</td>
             <td>$(item.description)</td>
             <td>$(item.quantity)</td>
             <td>$(item.price)</td>
             <td>$(item.quantity * item.price)</td>
           </tr>
# end
         <tr class="total-row">
           <td colspan="4" style="text-align: right;">Page Subtotal:</td>
           <td>$(page_sub_total)</td>
         </tr>
# if (is_last_page) then
         <tr class="total-row">
           <td colspan="4" style="text-align: right;">Grand Total:</td>
           <td>$(tablex.reduce(function(sum, item) return sum + (item.quantity * item.price); end, po_data.items, 0))</td>
         </tr>
# end
       </tbody>
     </table>
# if (not is_last_page) then
     <div class="page-break"></div>
# end
# end
</body>
</html>
]==];

local generate_html = function()
    local a, b, c = template.substitute(html, my_env);
    return a;
end

local generate_pdf = function()
    local str = generate_html();
    local pdf_data = chrome_pdf.generate(str, {
        display_header_footer = true,
        header_template = [[
                <div style="font-size:10px; width:100%; text-align:center;">
                    <span class="title"></span>
                </div>

            ]],
        footer_template = [[
                <div style="font-size:10px; width:100%; text-align:right; padding-right:20px;">
                    Page <span class="pageNumber"></span> of <span class="totalPages"></span>
                </div>
            ]],
        margin_top = 0.5,
        margin_bottom = 0.5,
        margin_left = 0.5,
        margin_right = 0.5,
        print_background = true,
        paper_width = 8.27,
        paper_height = 11.69
    });

    local file, err = io.open("purchase_order_with_page_totals.pdf", "wb")
    if not file then
        error("Failed to open file: " .. err)
    end
    file:write(pdf_data);
    file:close();

end

generate_pdf();

