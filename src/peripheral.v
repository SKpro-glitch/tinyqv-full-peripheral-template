/*
 * Copyright (c) 2025 Soham Sunil Kapur
 * SPDX-License-Identifier: Apache-2.0
 */

// Change the name of this module to something that reflects its functionality and includes your name for uniqueness
// For example tqvp_yourname_spi for an SPI peripheral.
// Then edit tt_wrapper.v line 41 and change tqvp_example to your chosen module name.

module soham_kapur_multi_sensor_response_check (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [5:0]   address,      // Address within this peripheral's address space
    input [31:0]  data_in,      // Data in to the peripheral, all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    input [1:0]   data_write_n, // Mode: 00, 11 = Off; 01 = Set; 10 = Run
    input [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    
    // Ultrasonic Sensor interface pins
    output [31:0] trig,
    input  [31:0] echo,
    
    output [31:0] data_out,           // Data out from the peripheral, all 32 bits are valid on read when user_interrupt is high.
    output        data_ready,
    
    output        user_interrupt      // Dedicated interrupt request for this peripheral
);


    reg [31:0] clk_counter=0, limit=0, below_limit=0, active_sensors=0;
    
    wire valid = clk_counter < limit;

    always @ (posedge clk) begin
        if(!rst_n) begin
        
            clk_counter <= 0;
            below_limit <= 0;
            trig <= 0;
            data_ready <= 1'b0;
        
        end
        else begin
            case(data_write_n)
                //Off Mode: The device is switched off as the clock counter is fixed to zero
                0: clk_counter <= 0;
                
                //Set Mode: The sesnor time limit can be set by the processor
                1: limit <= data_in;
                
                //Activate Mode: Which sensors are active and which are not, must be set through a bit mask
                2: active_sensors <= data_in;

                //Run Mode: The device runs and checks the respective sensors
                3: begin
                    if(clk_counter==0) //At the first clock cycle, the triggers are sent
                        trig <= {32{1'b1}};
                    else if(valid) //At each clock cycle, the echos are read
                        below_limit <= echo;                        
                    else //When clock cycles upto the limit have bee counted, the data is ready
                        data_ready <= 1'b1;

                    //Clock Counter increments at each clock cycle upto the limit in run mode
                    clk_counter <= clk_counter +  (valid ? 1 : 0);
                end
                
                default: clk_counter <= 0;
            endcase
        end
    end
    
    // The bottom 8 bits of the below_limit sensors are added to ui_in and output to uo_out.
    assign uo_out = below_limit[7:0] + ui_in;

    // Address 0 reads the below_limit register.  
    // Address 4 reads ui_in
    // All other addresses read 0.
    assign data_out = (address == 6'h0) ? below_limit :
                      (address == 6'h4) ? {24'h0, ui_in} :
                      32'h0;

    assign user_interrupt = |below_limit;

    // List all unused inputs to prevent warnings
    // data_read_n is unused as none of our behaviour depends on whether
    // registers are being read.
    wire _unused = &{data_read_n, 1'b0};

endmodule