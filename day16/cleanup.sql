drop table if exists day16_part2_instruction;
drop function if exists day16_assign_codes;
drop function if exists
  day16_two_registers, day16_register_and_value,
  day16_addr, day16_addi, day16_mulr, day16_muli, day16_banr, day16_bani, day16_borr, day16_bori,
  day16_setr, day16_seti, day16_gtir, day16_gtri, day16_gtrr, day16_eqir, day16_eqri, day16_eqrr,
  day16_operation;
drop table if exists day16_two_operands;
drop table if exists day16, day16_result, day16_operation_code, day16_match;
