#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"


MODULE = Local::Stats		PACKAGE = Local::Stats		

INCLUDE: const-xs.inc

void
add (r_self, name, value)
		SV *r_self;
		char *name;
		double value;
	CODE:
		// Check object
		if (!( SvOK(r_self) && SvROK(r_self) )) croak("object must be a hashref");
		SV *_self = SvRV(r_self);
		// Check type
		if (SvTYPE(_self) != SVt_PVHV) croak("object must be a hashref");
		// Cast to hash type
		HV *self = (HV*)_self;
		// Check keys
		if (!( hv_exists(self, "metrics", 7) && hv_exists(self, "code", 4) ))
			croak("object must contain keys 'metrics' and 'code'");
		// Fetch values
		SV **_metrics = hv_fetchs(self, "metrics", 0);
		SV **r__code = hv_fetchs(self, "code", 0);
		if (!( _metrics && r__code )) croak("Non allow NULL in metrics and code values");

		SV *r_metrics = *_metrics;
		if (!( SvOK(r_metrics) && SvROK(r_metrics) )) croak("metrics must be a hashref");
		SV *__metrics = SvRV(r_metrics);
		if (SvTYPE(__metrics) != SVt_PVHV) croak("metrics must be a hashref");
		HV *metrics = (HV*)__metrics;

		// Check code
		SV *__code = *r__code;
		if (!SvOK(__code)) croak("config must be a ref");
		SV *_code = SvRV(__code);
		if (SvTYPE(_code) != SVt_PVCV) croak("code must be a coderef");

		double old_sum, new_sum, new_avg, old_min, old_max, new_min, new_max;
		int old_cnt;

		if ( hv_exists(metrics, name, strlen(name)) ) {
			SV **r__config = hv_fetch(metrics, name, strlen(name), 0);
			if (!r__config) croak("Non allow NULL in metric config");
			SV *__config = *r__config;
			if (!SvOK(__config)) croak("config must be a hashref");
			SV *_config = SvRV(__config);
			if (SvTYPE(_config) != SVt_PVHV) croak("config must be a hashref");
			HV *config = (HV*)_config;

			if ( hv_exists(config, "sum", 3) ) {
				old_sum = SvNV(*(hv_fetch(config, "sum", 3, 0)));
				new_sum = old_sum + value;
				hv_store(config, "sum", 3, newSVnv(new_sum), 0);
			}
			if ( hv_exists(config, "cnt", 3) ) {
				old_cnt = SvIV(*(hv_fetch(config, "cnt", 3, 0)));
				hv_store(config, "cnt", 3, newSViv(old_cnt + 1), 0);
			}
			if ( hv_exists(config, "avg", 3) ) {
				new_avg = new_sum / (old_cnt + 1);
				hv_store(config, "avg", 3, newSVnv(new_avg), 0);
			}
			if ( hv_exists(config, "min", 3) ) {
				old_min = SvNV(*(hv_fetch(config, "min", 3, 0)));
				new_min = (old_min < value) ? old_min : value;
				hv_store(config, "min", 3, newSVnv(new_min), 0);
			}
			if ( hv_exists(config, "max", 3) ) {
				old_max = SvNV(*(hv_fetch(config, "max", 3, 0)));
				new_max = (old_max > value) ? old_max : value;
				hv_store(config, "max", 3, newSVnv(new_max), 0);
			}

		} else {
			// Call function
			HV* conf = newHV();
			dSP;
			ENTER;
	        SAVETMPS;
	        PUSHMARK(SP);
	        EXTEND(SP, 1);
	        mPUSHp(name, strlen(name));
	        PUTBACK;

	        int count = call_sv(_code, G_ARRAY);
	        int i;
	        SPAGAIN;
	        // Now arguments in stack
			// Catch them all
	        for (i = 0; i < count; i++) {
	        	char * arg = POPp;

	        	if (strcmp(arg,"cnt") == 0) {
	        		hv_store(conf, arg, 3, newSViv(1), 0);
	        	}  
	        	else if (strcmp(arg,"sum") == 0) {
	        		hv_store(conf, arg, 3, newSVnv(value), 0);
	        	}
	        	else if (strcmp(arg,"avg") == 0) {
	        		hv_store(conf, arg, 3, newSVnv(value), 0);
	        		hv_store(conf, "sum", 3, newSVnv(value), 0);
	        		hv_store(conf, "cnt", 3, newSViv(1), 0);
	        	}
	        	else if (strcmp(arg,"min") == 0) {
	        		hv_store(conf, arg, 3, newSVnv(value), 0);
	        	}
	        	else if (strcmp(arg,"max") == 0) {
	        		hv_store(conf, arg, 3, newSVnv(value), 0);
	        	}
	        }
	        FREETMPS;
	        LEAVE;
	        hv_store(metrics, name, strlen(name), newRV((SV *)conf), 0);
		}


SV*
stat (r_self)
		SV *r_self;
	CODE:
		// Check object
		if (!( SvOK(r_self) && SvROK(r_self) )) croak("object must be a hashref");
		SV *_self = SvRV(r_self);
		// Check type
		if (SvTYPE(_self) != SVt_PVHV) croak("object must be a hashref");
		// Cast to hash type
		HV *self = (HV*)_self;
		// Check keys
		if (!( hv_exists(self, "metrics", 7) && hv_exists(self, "code", 4) ))
			croak("object must contain keys 'metrics' and 'code'");
		// Fetch metrics and code
		SV **r__metrics = hv_fetchs(self, "metrics", 0);
		SV **r__code = hv_fetchs(self, "code", 0);
		if (!( r__metrics && r__code )) croak("Non allow NULL in metrics and code values");

		SV *__metrics = *r__metrics;
		if (!( SvOK(__metrics) && SvROK(__metrics) )) croak("metrics must be a hashref");
		SV *_metrics = SvRV(__metrics);
		if (SvTYPE(_metrics) != SVt_PVHV) croak("metrics must be a hashref");
		HV *metrics = (HV*)_metrics;

		SV *__code = *r__code;
		if (!SvOK(__code)) croak("config must be a ref");
		SV *_code = SvRV(__code);
		if (SvTYPE(_code) != SVt_PVCV) croak("code must be a coderef");

		HV* result = newHV();


		HV* copy_value = newHV();

		char *key;
	    I32 key_length;
	    SV *value;
	    HV *_value;

		hv_iterinit(metrics);
		while (value = hv_iternextsv(metrics, &key, &key_length)) {
			_value = (HV*)value;
			RETVAL = newRV((SV*)value);
		}

		SV** _val = hv_fetch(_value, "sum", 3, 0);
		// if (SvRV())
		
	OUTPUT:
		RETVAL