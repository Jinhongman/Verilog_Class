`timescale 1ns / 1ps

module RV32I_MCU (
    input  logic       clk,
    input  logic       reset,
    //GPI
    input  logic [3:0] inPort,
    //GPO
    output logic [3:0] outPort,
    //GPIO
    inout  logic [3:0] IOPortA,
    inout  logic [3:0] IOPortB,
    inout  logic [3:0] IOPortC,
    inout  logic [3:0] IOPortD,
    //UART
    input  logic       rx,
    output logic       tx,
    //FND
    output logic [3:0] fndCom,
    output logic [7:0] fndFont,
    //BUTTON
    input  logic       btnU
);
    logic [31:0] w_InstrMemAddr, w_InstrMemData;
    logic w_We;
    logic [31:0] w_Addr, w_dataMemRData, w_WData;
    logic [31:0] w_MasterRData;
    logic [10:0] w_slave_sel;
    logic [31:0]
        w_ReadDataGPI,
        w_ReadDataGPO,
        w_ReadDataGPIOA,
        w_ReadDataGPIOB,
        w_ReadDataGPIOC,
        w_ReadDataGPIOD,
        w_ReadDataFND,
        w_ReadDataUART,
        w_ReadDataBtn,
        w_ReadDataCounter;
    logic [2:0] loadType, StoreType;

    InstructionMemory U_ROM (
        .addr(w_InstrMemAddr),
        .data(w_InstrMemData)
    );
    CPU_Core U_CPU_Core (
        .clk(clk),
        .reset(reset),
        .machineCode(w_InstrMemData),
        .instrMemRAddr(w_InstrMemAddr),
        .dataMemRAddr(w_Addr),
        .dataMemRData(w_MasterRData),
        .dataMemWe(w_We),
        .dataMemWData(w_WData),
        .loadType(loadType),
        .StoreType(StoreType)
    );
    BUS_Interconnector U_BUS_Interconn (
        .address(w_Addr),
        .slave_sel(w_slave_sel),
        .slave_rdata1(w_dataMemRData),  //RAM
        .slave_rdata2(w_ReadDataGPI),  //GPI
        .slave_rdata3(w_ReadDataGPO),  //GPO
        .slave_rdata4(w_ReadDataGPIOA),  //GPIOA
        .slave_rdata5(w_ReadDataGPIOB),  //GPIOB
        .slave_rdata6(w_ReadDataGPIOC),  //GPIOC
        .slave_rdata7(w_ReadDataGPIOD),  //GPIOD
        .slave_rdata8(w_ReadDataFND),  //FND
        .slave_rdata9(w_ReadDataUART),  //UART
        .slave_rdata10(w_ReadDataBtn),  //UART
        .slave_rdata11(w_ReadDataCounter),  //UART

        .master_rdata(w_MasterRData)
    );
    DataMemory U_RAM (
        .clk(clk),
        .ce(w_slave_sel[0]),
        .we(w_We),
        .addr(w_Addr[7:0]),
        .wdata(w_WData),
        .rdata(w_dataMemRData),
        .loadType(loadType),
        .StoreType(StoreType)
    );
    GPI U_GPI (
        .clk(clk),
        .addr(w_Addr),
        .cs(w_slave_sel[1]),
        .we(w_We),
        .rdata(w_ReadDataGPI),
        .inPort(inPort)
    );
    GPO U_GPO (
        .clk(clk),
        .reset(reset),
        .ce(w_slave_sel[2]),
        .we(w_We),
        .addr(w_Addr[1:0]),
        .wdata(w_WData),
        .rdata(w_ReadDataGPO),
        .outPort(outPort)
    );
    GPIO U_GPIOA (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[3]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataGPIOA),
        .IOPort(IOPortA)
    );
    GPIO U_GPIOB (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[4]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataGPIOB),
        .IOPort(IOPortB)
    );
    GPIO U_GPIOC (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[5]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataGPIOC),
        .IOPort(IOPortC)
    );
    GPIO U_GPIOD (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[6]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataGPIOD),
        .IOPort(IOPortD)
    );
    FND U_FND (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[0]),
        .cs(w_slave_sel[7]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataFND),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );
    UART_FIFO_IP U_UART_FIFO_IP (
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[8]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataUART),
        .rx(rx),
        .tx(tx)
    );
    button_IP U_Button_IP(
       .clk(clk),
       .reset(reset),
       .addr(w_Addr),
       .cs(w_slave_sel[9]),
       .we(w_We),
       .inport(btnU),
       .rdata(w_ReadDataBtn)
    );

    /*
    downCounter U_DownCounter_IP(
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[10]),
        .we(w_We),
        .wdata(w_WData),
        .rdata(w_ReadDataCounter)
    );*/

    DownCounter_IP U_DownCounter_IP(
        .clk(clk),
        .reset(reset),
        .addr(w_Addr[3:0]),
        .cs(w_slave_sel[10]),
        .we(w_We),
        .wData(w_WData),
        .rData(w_ReadDataCounter)
    );

endmodule