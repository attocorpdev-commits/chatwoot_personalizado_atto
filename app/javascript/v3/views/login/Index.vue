<script>
// utils and composables
import { login } from '../../api/auth';
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { required, email } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';
import { SESSION_STORAGE_KEYS } from 'dashboard/constants/sessionStorage';
import SessionStorage from 'shared/helpers/sessionStorage';
import { useBranding } from 'shared/composables/useBranding';
import attoLogo from 'dashboard/assets/images/atto-logo.png';

// components
import SimpleDivider from '../../components/Divider/SimpleDivider.vue';
import FormInput from '../../components/Form/Input.vue';
import GoogleOAuthButton from '../../components/GoogleOauth/Button.vue';
import Spinner from 'shared/components/Spinner.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import MfaVerification from 'dashboard/components/auth/MfaVerification.vue';

const ERROR_MESSAGES = {
  'no-account-found': 'LOGIN.OAUTH.NO_ACCOUNT_FOUND',
  'business-account-only': 'LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY',
  'saml-authentication-failed': 'LOGIN.SAML.API.ERROR_MESSAGE',
  'saml-not-enabled': 'LOGIN.SAML.API.ERROR_MESSAGE',
};

const IMPERSONATION_URL_SEARCH_KEY = 'impersonation';

export default {
  components: {
    FormInput,
    GoogleOAuthButton,
    Spinner,
    NextButton,
    SimpleDivider,
    MfaVerification,
    Icon,
  },
  props: {
    ssoAuthToken: { type: String, default: '' },
    ssoAccountId: { type: String, default: '' },
    ssoConversationId: { type: String, default: '' },
    email: { type: String, default: '' },
    authError: { type: String, default: '' },
  },
  setup() {
    const { replaceInstallationName } = useBranding();
    return {
      replaceInstallationName,
      v$: useVuelidate(),
    };
  },
  data() {
    return {
      attoLogoUrl: attoLogo,
      credentials: {
        email: '',
        password: '',
      },
      loginApi: {
        message: '',
        showLoading: false,
        hasErrored: false,
      },
      error: '',
      mfaRequired: false,
      mfaToken: null,
    };
  },
  validations() {
    return {
      credentials: {
        password: {
          required,
        },
        email: {
          required,
          email,
        },
      },
    };
  },
  computed: {
    ...mapGetters({ globalConfig: 'globalConfig/get' }),
    allowedLoginMethods() {
      return window.chatwootConfig.allowedLoginMethods || ['email'];
    },
    showGoogleOAuth() {
      return (
        this.allowedLoginMethods.includes('google_oauth') &&
        Boolean(window.chatwootConfig.googleOAuthClientId)
      );
    },
    showSignupLink() {
      return window.chatwootConfig.signupEnabled === 'true';
    },
    showSamlLogin() {
      return this.allowedLoginMethods.includes('saml');
    },
  },
  created() {
    if (this.ssoAuthToken) {
      this.submitLogin();
    }
    if (this.authError) {
      const messageKey = ERROR_MESSAGES[this.authError] ?? 'LOGIN.API.UNAUTH';
      const translatedMessage = this.getTranslatedMessage(messageKey);
      useAlert(translatedMessage);
      this.requestIdleCallbackPolyfill(() => {
        const { query } = this.$route;
        this.$router.replace({ query: { ...query, error: undefined } });
      });
    }
  },
  methods: {
    getTranslatedMessage(key) {
      switch (key) {
        case 'LOGIN.OAUTH.NO_ACCOUNT_FOUND':
          return this.$t('LOGIN.OAUTH.NO_ACCOUNT_FOUND');
        case 'LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY':
          return this.$t('LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY');
        case 'LOGIN.API.UNAUTH':
        default:
          return this.$t('LOGIN.API.UNAUTH');
      }
    },
    requestIdleCallbackPolyfill(callback) {
      if (window.requestIdleCallback) {
        window.requestIdleCallback(callback);
      } else {
        setTimeout(callback, 0);
      }
    },
    showAlertMessage(message) {
      this.loginApi.showLoading = false;
      this.loginApi.message = message;
      useAlert(this.loginApi.message);
    },
    handleImpersonation() {
      const urlParams = new URLSearchParams(window.location.search);
      const impersonation = urlParams.get(IMPERSONATION_URL_SEARCH_KEY);
      if (impersonation) {
        SessionStorage.set(SESSION_STORAGE_KEYS.IMPERSONATION_USER, true);
      }
    },
    submitLogin() {
      this.loginApi.hasErrored = false;
      this.loginApi.showLoading = true;

      const credentials = {
        email: this.email
          ? decodeURIComponent(this.email)
          : this.credentials.email,
        password: this.credentials.password,
        sso_auth_token: this.ssoAuthToken,
        ssoAccountId: this.ssoAccountId,
        ssoConversationId: this.ssoConversationId,
      };

      login(credentials)
        .then(result => {
          if (result?.mfaRequired) {
            this.loginApi.showLoading = false;
            this.mfaRequired = true;
            this.mfaToken = result.mfaToken;
            return;
          }

          this.handleImpersonation();
          this.showAlertMessage(this.$t('LOGIN.API.SUCCESS_MESSAGE'));
        })
        .catch(response => {
          if (this.email) {
            window.location = '/app/login';
          }
          this.loginApi.hasErrored = true;
          this.showAlertMessage(
            response?.message || this.$t('LOGIN.API.UNAUTH')
          );
        });
    },
    submitFormLogin() {
      if (this.v$.credentials.email.$invalid && !this.email) {
        this.showAlertMessage(this.$t('LOGIN.EMAIL.ERROR'));
        return;
      }

      this.submitLogin();
    },
    handleMfaVerified() {
      this.handleImpersonation();
      window.location = '/app';
    },
    handleMfaCancel() {
      this.mfaRequired = false;
      this.mfaToken = null;
      this.credentials.password = '';
    },
  },
};
</script>

<template>
  <main class="flex min-h-screen dark:bg-n-background bg-n-brand/5">
    <!-- ── Painel esquerdo: marca (oculto em mobile) ── -->
    <div
      class="hidden lg:flex lg:w-[460px] xl:w-[500px] flex-shrink-0 flex-col justify-between p-12 relative overflow-hidden bg-gradient-to-br from-[#060c1d] via-[#0a1628] to-[#060a10]"
    >
      <!-- Grade de pontos decorativa -->
      <div
        class="absolute inset-0 opacity-[0.06] bg-[radial-gradient(circle,rgba(126,179,255,0.8)_1px,transparent_1px)] [background-size:28px_28px]"
      />
      <!-- Glow azul decorativo -->
      <div
        class="absolute -bottom-24 -left-24 w-[480px] h-[480px] rounded-full opacity-10 bg-[radial-gradient(circle,#3B63A8,transparent_70%)]"
      />

      <!-- Logo -->
      <div class="relative z-10">
        <img :src="attoLogoUrl" alt="Atto CRM" class="h-8 w-auto" />
      </div>

      <!-- Tagline + features -->
      <div class="relative z-10 space-y-8">
        <div>
          <h1 class="text-[2rem] font-semibold text-white leading-[1.2]">
            {{ $t('LOGIN.BRAND_PANEL.TAGLINE_1') }}<br />{{
              $t('LOGIN.BRAND_PANEL.TAGLINE_2')
            }}
          </h1>
          <p class="mt-3 text-[#7EB3FF]/60 text-[15px] leading-relaxed">
            {{ $t('LOGIN.BRAND_PANEL.SUBTITLE') }}
          </p>
        </div>
        <ul class="space-y-4">
          <li class="flex items-center gap-3">
            <span
              class="size-9 rounded-xl bg-[#3B63A8]/20 flex items-center justify-center flex-shrink-0"
            >
              <span
                class="i-lucide-message-circle size-[18px] text-[#7EB3FF]"
              />
            </span>
            <span class="text-n-slate-10 text-sm leading-snug">
              {{ $t('LOGIN.BRAND_PANEL.FEATURE_1') }}
            </span>
          </li>
          <li class="flex items-center gap-3">
            <span
              class="size-9 rounded-xl bg-[#3B63A8]/20 flex items-center justify-center flex-shrink-0"
            >
              <span class="i-lucide-users size-[18px] text-[#7EB3FF]" />
            </span>
            <span class="text-n-slate-10 text-sm leading-snug">
              {{ $t('LOGIN.BRAND_PANEL.FEATURE_2') }}
            </span>
          </li>
          <li class="flex items-center gap-3">
            <span
              class="size-9 rounded-xl bg-[#3B63A8]/20 flex items-center justify-center flex-shrink-0"
            >
              <span class="i-lucide-trending-up size-[18px] text-[#7EB3FF]" />
            </span>
            <span class="text-n-slate-10 text-sm leading-snug">
              {{ $t('LOGIN.BRAND_PANEL.FEATURE_3') }}
            </span>
          </li>
        </ul>
      </div>

      <!-- Rodapé -->
      <div class="relative z-10">
        <p class="text-xs text-n-slate-8">
          {{ $t('LOGIN.BRAND_PANEL.FOOTER') }}
        </p>
      </div>
    </div>

    <!-- ── Painel direito: formulário ── -->
    <div
      class="flex flex-1 flex-col items-center justify-center px-6 py-12 sm:px-12"
    >
      <!-- Logo visível apenas em mobile -->
      <img
        :src="attoLogoUrl"
        alt="Atto CRM"
        class="lg:hidden h-10 mb-8 mx-auto"
      />

      <div class="w-full max-w-md">
        <!-- Cabeçalho do formulário -->
        <div class="mb-8">
          <h2 class="text-2xl font-semibold text-n-slate-12">
            {{ replaceInstallationName($t('LOGIN.TITLE')) }}
          </h2>
          <p v-if="showSignupLink" class="mt-2 text-sm text-n-slate-11">
            {{ $t('COMMON.OR') }}
            <router-link
              to="auth/signup"
              class="lowercase text-link text-n-brand"
            >
              {{ $t('LOGIN.CREATE_NEW_ACCOUNT') }}
            </router-link>
          </p>
        </div>

        <!-- MFA -->
        <section v-if="mfaRequired">
          <MfaVerification
            :mfa-token="mfaToken"
            @verified="handleMfaVerified"
            @cancel="handleMfaCancel"
          />
        </section>

        <!-- Formulário de login -->
        <section
          v-else
          class="dark:bg-n-solid-2 bg-white rounded-xl p-8 shadow-sm outline outline-1 outline-n-container"
          :class="{ 'animate-wiggle': loginApi.hasErrored }"
        >
          <div v-if="!email">
            <div class="flex flex-col gap-4 mb-5">
              <GoogleOAuthButton v-if="showGoogleOAuth" />
              <div v-if="showSamlLogin" class="text-center">
                <router-link
                  to="/app/login/sso"
                  class="inline-flex justify-center w-full px-4 py-3 items-center bg-n-background dark:bg-n-solid-3 rounded-md shadow-sm ring-1 ring-inset ring-n-container dark:ring-n-container focus:outline-offset-0 hover:bg-n-alpha-2 dark:hover:bg-n-alpha-2"
                >
                  <Icon
                    icon="i-lucide-lock-keyhole"
                    class="size-5 text-n-slate-11"
                  />
                  <span class="ml-2 text-base font-medium text-n-slate-12">
                    {{ $t('LOGIN.SAML.LABEL') }}
                  </span>
                </router-link>
              </div>
              <SimpleDivider
                v-if="showGoogleOAuth || showSamlLogin"
                :label="$t('COMMON.OR')"
                class="uppercase"
              />
            </div>
            <form class="space-y-5" @submit.prevent="submitFormLogin">
              <FormInput
                v-model="credentials.email"
                name="email_address"
                type="text"
                data-testid="email_input"
                :tabindex="1"
                required
                :label="$t('LOGIN.EMAIL.LABEL')"
                :placeholder="$t('LOGIN.EMAIL.PLACEHOLDER')"
                :has-error="v$.credentials.email.$error"
                @input="v$.credentials.email.$touch"
              />
              <FormInput
                v-model="credentials.password"
                type="password"
                name="password"
                data-testid="password_input"
                required
                :tabindex="2"
                :label="$t('LOGIN.PASSWORD.LABEL')"
                :placeholder="$t('LOGIN.PASSWORD.PLACEHOLDER')"
                :has-error="v$.credentials.password.$error"
                @input="v$.credentials.password.$touch"
              >
                <p v-if="!globalConfig.disableUserProfileUpdate">
                  <router-link
                    to="auth/reset/password"
                    class="text-sm text-link"
                    tabindex="4"
                  >
                    {{ $t('LOGIN.FORGOT_PASSWORD') }}
                  </router-link>
                </p>
              </FormInput>
              <NextButton
                lg
                type="submit"
                data-testid="submit_button"
                class="w-full"
                :tabindex="3"
                :label="$t('LOGIN.SUBMIT')"
                :disabled="loginApi.showLoading"
                :is-loading="loginApi.showLoading"
              />
            </form>
          </div>
          <div v-else class="flex items-center justify-center">
            <Spinner color-scheme="primary" size="" />
          </div>
        </section>
      </div>
    </div>
  </main>
</template>
