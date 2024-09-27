
* SAP ABAP Programming and HANA Database Tutorials
* Report Program Framework in ABAP
*&---------------------------------------------------------------------*
*& Report ZST2FRAMEWORK
*&---------------------------------------------------------------------*
*& Generic report program framework
*  This program is a generic framework for creating report programs.
*  It is designed to be used as a starting point for creating new report programs.
* The program is divided into three classes:
* 1. Exception class - lcx_error
* 2. Startup class - lcl_start
* 3. Main processing class - lcl_main
* The program is designed to be run as a report program.
* The program uses the TRY-CATCH-ENDTRY statement to handle exceptions.
* The program uses the RAISING clause to raise exceptions.
* The program uses the MESSAGE statement to display messages.

*&---------------------------------------------------------------------*
REPORT zst2calc.

***********************************************************************
* Selection screen definition
* We firstly add the parameters of the report when using a report development framework like this for ABAP
***********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.

  PARAMETERS: p_input1 TYPE i,
              p_input2 TYPE i.

  " next one creates text inputs for each parameter

SELECTION-SCREEN END OF BLOCK main.

* Remember that our framework requires that we pass the selection screen values as parameters to the main processing
* class CONSTRUCTOR method, so next we must define those parameters in the CONSTRUCTOR method definition.

***********************************************************************
* Exception class definition
***********************************************************************
CLASS lcx_error DEFINITION
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES:
      if_t100_message.

    CONSTANTS:
      exception_lcx_error TYPE string
        VALUE 'LCX_ERROR'.

*   Add additional exception type texts and objects

    CONSTANTS:
      BEGIN OF lcx_error,
*     --> Default exception type
        msgid TYPE symsgid VALUE 'ZST2_GENERAL',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'EXCEPTION_LCX_ERROR',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF lcx_error.

    METHODS:
      constructor
        IMPORTING
          textid   LIKE if_t100_message=>t100key OPTIONAL
          previous LIKE previous OPTIONAL.

ENDCLASS.


***********************************************************************
* Startup class definition
***********************************************************************
CLASS lcl_start DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      mc_error  TYPE bapi_mtype VALUE 'E',
      mc_status TYPE bapi_mtype VALUE 'S'.

    CLASS-DATA:
*     Generic error object
      mo_error TYPE REF TO cx_root.

    CLASS-METHODS:
      run
        RAISING lcx_error.

ENDCLASS.


***********************************************************************
* Main processing class definition
***********************************************************************
CLASS lcl_main DEFINITION.

  PUBLIC SECTION.

* Uncomment for one-time INITIALIZATION routines
*    CLASS-METHODS:
*      class_constructor.

* We will add two IMPORTING parameters to the method definition
    METHODS:
      constructor
        IMPORTING
                  iv_input1 TYPE i
                  iv_input2 TYPE i
        RAISING   lcx_error.

  PRIVATE SECTION.
*   create a private class attribute to store the result of the calculation.
   DATA: mv_result TYPE i.
   METHODS:
    add_values
      IMPORTING
        iv_number1 TYPE i
        iv_number2 TYPE i
      RETURNING VALUE(rv_result) TYPE i,

   display_result
    IMPORTING
      rv_result TYPE i.

ENDCLASS.


***********************************************************************
* Program starts here
***********************************************************************
START-OF-SELECTION.
  TRY.
      lcl_start=>run( ).
    CATCH cx_root INTO lcl_start=>mo_error.
      MESSAGE lcl_start=>mo_error TYPE lcl_start=>mc_status
                                  DISPLAY LIKE  lcl_start=>mc_error.
  ENDTRY.


***********************************************************************
* Exception class implementation
***********************************************************************
CLASS lcx_error IMPLEMENTATION.

  METHOD constructor.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    CLEAR me->textid.

    IF textid IS INITIAL.
*     Raise default exception type
      if_t100_message~t100key = lcx_error.
    ELSE.
      if_t100_message~t100key = textid.

*   Transfer additional exception texts here

    ENDIF.

  ENDMETHOD.

ENDCLASS.


***********************************************************************
* Startup class implementation
***********************************************************************
CLASS lcl_start IMPLEMENTATION.

  METHOD run.

*   Add the screen parameters as arguments to the constructor of the lcl_main class
    DATA(lo_main) = NEW lcl_main( iv_input1 = p_input1
                                 iv_input2 = p_input2 ).

  ENDMETHOD.

ENDCLASS.


***********************************************************************
* Main processing class implementation
***********************************************************************
CLASS lcl_main IMPLEMENTATION.

* Uncomment for one-time INITIALIZATION routines
*  METHOD class_constructor.
*
**   Add code for implementation
*
*  ENDMETHOD.


  METHOD constructor.
" ----------------------- here we add the functionality/processing of the report ---------------------------
  mv_result = add_values( iv_number1 =  iv_input1 iv_number2 = iv_input2 ).
  display_result( mv_result ).

  " next we need to implement the two methods that got appealed above add_values() and display_result().
  ENDMETHOD.

  METHOD add_values.
     rv_result = iv_number1 + iv_number2.
  ENDMETHOD.

  METHOD display_result.

  DATA lv_text TYPE text40.
  WRITE rv_result TO lv_text LEFT-JUSTIFIED.
  lv_text = TEXT-t01 && lv_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT' EXPORTING textline1 = lv_text.

  ENDMETHOD.

ENDCLASS.
