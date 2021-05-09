-------------------------------------------------------------------------
-- Design unit: Util package
-- Description: Package with some general functions/procedures
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package CORDIC_package is

   type Command is record
        wr_ang_rs_xySa	: std_logic;
        wr_it_rs_i	    : std_logic;
        wr_xy 	        : std_logic;
        wr_i            : std_logic;
        wr_sA           : std_logic;
        wr_xNew_rs_shifr: std_logic;
        wr_yNew         : std_logic;
        rs_m1,rs_m2     : std_logic_vector(2 downto 0);
    end record;

end CORDIC_package;
