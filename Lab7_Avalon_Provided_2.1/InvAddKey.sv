module InvAddKey (
    input logic [127:0] data_in, key,
    output logic [127:0] data_out
);

    assign data_out = data_in ^ key;

endmodule