            DROP FUNCTION IF EXISTS get_defaulted_loanapps_bytermdate(date, date, date);

            CREATE OR REPLACE FUNCTION get_defaulted_loanapps_bytermdate(IN date, IN date, IN date)
            RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric) AS
            $BODY$
            BEGIN

            RETURN QUERY
            SELECT dl.loanappid AS r1,
            dl.loanproduct AS r2,
            dl.loanproductid AS r3,
            dl.refnr AS r4,
            dl.firstname AS r5,
            dl.lastname AS r6,
            dl.score AS r7,
            dl.office AS r8,
            dl.incassocompany AS r9,
            dl.incassocompanyid AS r10,
            dl.loanamount AS r11,
            dl.loanperiod AS r12,
            dl.activedate AS r13,
            dl.defaulteddate AS r14,
            dl.collectiondate AS r15,
            dl.totaldebt AS r16,
            dl.principal AS r17,
            dl.commissionfee AS r18,
            dl.interest AS r19,
            dl.firstrem AS r20,
            dl.secondrem AS r21,
            dl.termalertfee AS r22,
            dl.termfee AS r23,
            dl.suspensionfee AS r24,
            dl.delayinterest AS r25,
            dl.repaymentslater AS r26,
            dl.guaranteefee AS r27,
            dl.adminfee AS r28,
            dl.agreementsignment AS r29,
            dl.payoutto AS r30,
            dl.firstremsms AS r31,
            dl.secondremsms AS r32,
            dl.thirdremsms AS r33,
            dl.fourthremsms AS r34,
            dl.fifthremsms AS r35
            FROM get_defaulted_loanapps_base($1, $2, $3) dl

            WHERE dl.defaulteddate::date >=$1 AND dl.defaulteddate::date<=$2
            ORDER BY dl.defaulteddate ASC, dl.refnr ASC
            ;

            END;
            $BODY$
            LANGUAGE plpgsql VOLATILE;

            DROP FUNCTION IF EXISTS get_defaulted_loanapps_byinternaldate(date, date, date);
            CREATE OR REPLACE FUNCTION get_defaulted_loanapps_byinternaldate(IN date, IN date, IN date)
            RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric) AS
            $BODY$
            BEGIN

            RETURN QUERY
            SELECT dl.loanappid AS r1,
            dl.loanproduct AS r2,
            dl.loanproductid AS r3,
            dl.refnr AS r4,
            dl.firstname AS r5,
            dl.lastname AS r6,
            dl.score AS r7,
            dl.office AS r8,
            dl.incassocompany AS r9,
            dl.incassocompanyid AS r10,
            dl.loanamount AS r11,
            dl.loanperiod AS r12,
            dl.activedate AS r13,
            dl.defaulteddate AS r14,
            dl.collectiondate AS r15,
            dl.totaldebt AS r16,
            dl.principal AS r17,
            dl.commissionfee AS r18,
            dl.interest AS r19,
            dl.firstrem AS r20,
            dl.secondrem AS r21,
            dl.termalertfee AS r22,
            dl.termfee AS r23,
            dl.suspensionfee AS r24,
            dl.delayinterest AS r25,
            dl.repaymentslater AS r26,
            dl.guaranteefee AS r27,
            dl.adminfee AS r28,
            dl.agreementsignment AS r29,
            dl.payoutto AS r30,
            dl.firstremsms AS r31,
            dl.secondremsms AS r32,
            dl.thirdremsms AS r33,
            dl.fourthremsms AS r34,
            dl.fifthremsms AS r35
            FROM get_internal_collection_loanapps_base($1, $2, $3) dl

            WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
            ORDER BY dl.collectiondate ASC, dl.refnr ASC;

            END;
            $BODY$
            LANGUAGE plpgsql VOLATILE;

            DROP FUNCTION IF EXISTS get_defaulted_loanapps_bycollectiondate(date, date, date);

            CREATE OR REPLACE FUNCTION get_defaulted_loanapps_bycollectiondate(IN date, IN date, IN date)
            RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric) AS
            $BODY$
            BEGIN

            RETURN QUERY
            SELECT dl.loanappid AS r1,
            dl.loanproduct AS r2,
            dl.loanproductid AS r3,
            dl.refnr AS r4,
            dl.firstname AS r5,
            dl.lastname AS r6,
            dl.score AS r7,
            dl.office AS r8,
            dl.incassocompany AS r9,
            dl.incassocompanyid AS r10,
            dl.loanamount AS r11,
            dl.loanperiod AS r12,
            dl.activedate AS r13,
            dl.defaulteddate AS r14,
            dl.collectiondate AS r15,
            dl.totaldebt AS r16,
            dl.principal AS r17,
            dl.commissionfee AS r18,
            dl.interest AS r19,
            dl.firstrem AS r20,
            dl.secondrem AS r21,
            dl.termalertfee AS r22,
            dl.termfee AS r23,
            dl.suspensionfee AS r24,
            dl.delayinterest AS r25,
            dl.repaymentslater AS r26,
            dl.guaranteefee AS r27,
            dl.adminfee AS r28,
            dl.agreementsignment AS r29,
            dl.payoutto AS r30,
            dl.firstremsms AS r31,
            dl.secondremsms AS r32,
            dl.thirdremsms AS r33,
            dl.fourthremsms AS r34,
            dl.fifthremsms AS r35
            FROM get_indebtcollection_loanapps_base($1, $2, $3) dl

            WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
            ORDER BY dl.collectiondate ASC, dl.refnr ASC

            ;

            END;
            $BODY$
            LANGUAGE plpgsql VOLATILE;