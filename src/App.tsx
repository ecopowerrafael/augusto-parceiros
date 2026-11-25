import { useEffect, useState } from 'react'
import { ArrowUpRight, Check, ChevronDown, Menu, MessageCircle, ShieldCheck, X } from 'lucide-react'
import { whatsappLink } from './whatsapp'
import type { RuntimeConfig } from './runtime-config'
import { BrandLogo } from './components/BrandLogo'
import { ClientRegistrationPage, DashboardPage, LoginPage, PartnerRegistrationPage, PasswordRecoveryPage, ResetPasswordPage, StatusPage } from './auth/AuthPages'

const wa = whatsappLink

const services = [
  { id: 'motor', title: 'Cadastro de Motor', text: 'Regularização de motores substituídos em carros, motos e caminhões, com ou sem nota fiscal, mediante análise de viabilidade.', image: '/assets/service-motor.png', label: 'Análise de motor' },
  { id: 'suspensao', title: 'Suspensão Rebaixada', text: 'Assessoria para regularização de veículos com suspensão modificada, incluindo orientação sobre documentos e inspeções.', image: '/assets/service-suspensao.png', label: 'Suspensão' },
  { id: 'rodas', title: 'Pneus e Rodas', text: 'Análise das alterações realizadas nas rodas e pneus do veículo e orientação sobre os procedimentos aplicáveis.', image: '/assets/service-rodas.png', label: 'Rodas e pneus' },
  { id: 'modificados', title: 'Veículos Modificados', text: 'Soluções para regularização de alterações nas características originais do veículo, mediante avaliação técnica e documental.', image: '/assets/service-modificados.png', label: 'Modificações' },
]

const partners = ['Desmanches', 'Autopeças', 'Vendedores de motores', 'Oficinas mecânicas', 'Retíficas', 'Lojas de rodas e pneus', 'Empresas de suspensão', 'Preparadores automotivos', 'Lojistas de veículos']
const faqs = [
  ['É possível cadastrar um motor sem nota fiscal?', 'A ausência da nota não encerra a análise automaticamente. O caso depende da origem do motor, dos documentos disponíveis e das exigências aplicáveis. Faremos uma avaliação antes de indicar os próximos passos.'],
  ['É possível cadastrar um motor usado?', 'Sim, motores usados podem ser analisados. Precisamos verificar a origem, a identificação do motor e a compatibilidade técnica com o veículo de destino.'],
  ['O motor precisa ter baixa no veículo de origem?', 'Essa é uma informação importante para a análise documental. A orientação pode variar conforme a origem do conjunto e a documentação apresentada.'],
  ['Posso instalar um motor mais potente?', 'Pode haver caminhos de regularização, mas não há garantia de aprovação. Diferenças de potência, cilindrada e combustível precisam ser analisadas individualmente.'],
  ['É possível regularizar suspensão rebaixada?', 'Em muitos casos existe um procedimento de análise e inspeção. A viabilidade depende das características da alteração e da documentação do veículo.'],
  ['Como regularizar rodas e pneus modificados?', 'Avaliamos as medidas, a aplicação no veículo e os documentos necessários para orientar o procedimento adequado.'],
  ['Quais documentos são necessários?', 'A lista depende do serviço. Em geral, documentos do proprietário, do veículo e da alteração realizada são solicitados após a análise inicial.'],
  ['Como funciona a parceria para desmanches e autopeças?', 'Você indica o cliente e nossa equipe conduz a análise documental. A plataforma digital de parceiros está em desenvolvimento; por enquanto, o atendimento é feito diretamente pelo WhatsApp.'],
]

function CommercialApp() {
  const [runtimeConfig, setRuntimeConfig] = useState<RuntimeConfig | undefined>(window.__DOC_MOTOR_CONFIG__)
  const [menuOpen, setMenuOpen] = useState(false)
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const [form, setForm] = useState({ name: '', company: '', segment: '', city: '', state: '', whatsapp: '', email: '', message: '' })

  const update = (key: keyof typeof form, value: string) => setForm((current) => ({ ...current, [key]: value }))
  const partnershipMessage = () => `Olá, Doc Motor! Tenho interesse em ser parceiro.\n\nNome: ${form.name}\nEmpresa: ${form.company}\nSegmento: ${form.segment}\nCidade/UF: ${form.city} - ${form.state}\nWhatsApp: ${form.whatsapp}\nE-mail: ${form.email || 'Não informado'}\nMensagem: ${form.message || 'Gostaria de conhecer as condições da parceria.'}`

  useEffect(() => {
    if (!runtimeConfig) fetch('/api/runtime-config').then((response) => response.ok ? response.json() as Promise<RuntimeConfig> : undefined).then(setRuntimeConfig).catch(() => undefined)
  }, [runtimeConfig])

  return <div className="site-shell">
    {runtimeConfig?.appEnv === 'staging' && <div className="staging-banner" role="status">Ambiente de homologação — sistema em desenvolvimento.</div>}
    <header className="site-header">
      <a className="brand" href="#inicio" aria-label="Doc Motor, início"><BrandLogo /></a>
      <button className="menu-toggle" aria-label={menuOpen ? 'Fechar menu' : 'Abrir menu'} onClick={() => setMenuOpen(!menuOpen)}>{menuOpen ? <X /> : <Menu />}</button>
      <nav className={menuOpen ? 'main-nav is-open' : 'main-nav'} aria-label="Navegação principal">
        <a href="#servicos" onClick={() => setMenuOpen(false)}>Serviços</a><a href="#como-funciona" onClick={() => setMenuOpen(false)}>Como funciona</a><a href="#parceiro" onClick={() => setMenuOpen(false)}>Seja parceiro</a><a href="#faq" onClick={() => setMenuOpen(false)}>Dúvidas</a><a href="#contato" onClick={() => setMenuOpen(false)}>Contato</a>
        <a className="nav-cta" href="/area-do-parceiro" onClick={(event) => { event.preventDefault(); alert('A Área do parceiro está em desenvolvimento. Fale conosco pelo WhatsApp para começar.') }}>Área do parceiro <ArrowUpRight size={16} /></a>
      </nav>
    </header>

    <main>
      <section className="hero" id="inicio">
        <div className="hero-media" aria-hidden="true"><img src="/assets/hero.png" alt="" /></div>
        <div className="hero-content container"><p className="eyebrow"><span /> DOCUMENTAÇÃO VEICULAR</p><h1>Seu veículo modificado.<br /><em>Sua documentação em dia.</em></h1><p className="hero-copy">Especialistas em soluções para regularização de motores, suspensão, rodas, pneus e modificações veiculares.</p><div className="hero-actions"><a className="button button-primary" href={wa('Olá, Doc Motor! Gostaria de solicitar um orçamento.')}>Solicitar orçamento <ArrowUpRight size={18} /></a><a className="button button-ghost" href="#parceiro">Seja nosso parceiro <ArrowUpRight size={18} /></a></div><div className="hero-note"><ShieldCheck size={18} /><span>Análise responsável, sem promessas de aprovação.</span></div></div>
        <div className="hero-scroll">ROLE PARA EXPLORAR <span>↓</span></div>
      </section>

      <section className="intro section container"><div className="section-kicker">01 / O QUE FAZEMOS</div><div><h2>Seu projeto merece<br /><span>clareza e direção.</span></h2></div><div className="intro-text"><p>Trocou o motor, rebaixou a suspensão ou modificou seu veículo? Conheça as possibilidades de regularização e solicite uma análise do seu caso.</p><a className="text-link" href="#servicos">Conheça nossos serviços <ArrowUpRight size={17} /></a></div></section>

      <section className="services section" id="servicos"><div className="container"><div className="section-heading"><div><div className="section-kicker">02 / NOSSOS SERVIÇOS</div><h2>Soluções para cada<br /><span>tipo de alteração.</span></h2></div><p>Orientação técnica e documental para você seguir com mais segurança em cada etapa.</p></div><div className="service-grid">{services.map((service, index) => <article className="service-card" key={service.id}><div className="service-image"><img src={service.image} alt={service.label} loading="lazy" /><span>0{index + 1}</span></div><div className="service-body"><h3>{service.title}</h3><p>{service.text}</p><a href={wa(`Olá, Doc Motor! Gostaria de saber mais sobre ${service.title}.`)} aria-label={`Solicitar orçamento de ${service.title}`}>Solicitar análise <ArrowUpRight size={17} /></a></div></article>)}</div></div></section>

      <section className="partner-feature" id="parceiro"><div className="partner-image" aria-hidden="true"><img src="/assets/partner.png" alt="" /></div><div className="partner-content container"><div className="section-kicker light">03 / PARA EMPRESAS</div><p className="partner-overline">Você vende o motor,<br />mas ainda não oferece a regularização?</p><h2>Então você está<br /><strong>perdendo dinheiro.</strong></h2><p className="partner-copy">Transforme cada venda de motor em uma nova oportunidade de lucro. Seus clientes precisam não apenas comprar um motor, mas também regularizar a substituição junto ao Detran.</p><ul>{['Ganhe com a indicação de serviços.', 'Ofereça uma solução mais completa aos seus clientes.', 'Aumente suas oportunidades de venda.', 'Trabalhe sem executar a burocracia documental.', 'Tenha acesso à futura plataforma de orçamentos.', 'Acompanhe suas solicitações online.'].map((item) => <li key={item}><Check size={16} />{item}</li>)}</ul><a className="button button-red" href="#formulario">Quero ser parceiro <ArrowUpRight size={18} /></a><small>A plataforma digital de parceiros está em desenvolvimento. Até lá, nossa equipe atende você diretamente.</small></div></section>

      <section className="audience section container"><div className="audience-copy"><div className="section-kicker">04 / PARA QUEM É</div><h2>Feito para quem<br /><span>move o mercado.</span></h2><p>Se você trabalha com veículos, peças ou alterações automotivas, pode oferecer mais valor aos seus clientes com uma orientação especializada.</p></div><div className="partner-tags">{partners.map((partner) => <div className="partner-tag" key={partner}><span>↗</span>{partner}</div>)}</div></section>

      <section className="steps section" id="como-funciona"><div className="container"><div className="section-kicker">05 / COMO FUNCIONA</div><div className="steps-heading"><h2>Do primeiro contato<br /><span>à documentação em dia.</span></h2><p>Um processo simples, transparente e conduzido por quem entende do assunto.</p></div><div className="steps-grid"><div><div className="step-label">PARA CLIENTES</div>{['Informe os dados do veículo.', 'Receba uma análise e orçamento.', 'Envie a documentação necessária.', 'Acompanhe a regularização.'].map((step, index) => <div className="step" key={step}><b>0{index + 1}</b><span>{step}</span></div>)}</div><div><div className="step-label">PARA PARCEIROS</div>{['Cadastre seu interesse.', 'Apresente nossos serviços aos seus clientes.', 'Solicite orçamentos.', 'Ganhe com os serviços indicados.'].map((step, index) => <div className="step" key={step}><b>0{index + 1}</b><span>{step}</span></div>)}</div></div></div></section>

      <section className="faq section container" id="faq"><div className="faq-intro"><div className="section-kicker">06 / PERGUNTAS FREQUENTES</div><h2>Antes de começar,<br /><span>tire suas dúvidas.</span></h2><p>Informação clara para você tomar a melhor decisão sobre o seu veículo.</p><a href={wa('Olá, Doc Motor! Tenho uma dúvida sobre regularização veicular.')} className="text-link">Falar com um especialista <ArrowUpRight size={17} /></a></div><div className="faq-list">{faqs.map(([question, answer], index) => <div className={openFaq === index ? 'faq-item is-open' : 'faq-item'} key={question}><button onClick={() => setOpenFaq(openFaq === index ? null : index)} aria-expanded={openFaq === index}><span>{question}</span><ChevronDown size={18} /></button>{openFaq === index && <p>{answer}</p>}</div>)}</div></section>

      <section className="contact section" id="contato"><div className="container contact-grid"><div><div className="section-kicker light">07 / FALE COM A GENTE</div><h2>Vamos colocar<br /><strong>seu projeto</strong><br />em movimento?</h2><p>Conte o que você precisa. Nossa equipe orienta os próximos passos pelo WhatsApp.</p><a className="contact-phone" href="https://wa.me/5515997118125"><MessageCircle size={20} />(15) 99711-8125</a></div><div className="contact-card" id="formulario"><div className="card-label">INTERESSE EM PARCERIA</div><h3>Vamos conversar?</h3><p>Preencha seus dados e envie uma mensagem organizada pelo WhatsApp.</p><div className="form-grid"><input aria-label="Nome" placeholder="Seu nome *" value={form.name} onChange={(event) => update('name', event.target.value)} /><input aria-label="Empresa" placeholder="Nome da empresa *" value={form.company} onChange={(event) => update('company', event.target.value)} /><input aria-label="Segmento" placeholder="Segmento *" value={form.segment} onChange={(event) => update('segment', event.target.value)} /><input aria-label="Cidade" placeholder="Cidade *" value={form.city} onChange={(event) => update('city', event.target.value)} /><input aria-label="Estado" placeholder="Estado *" maxLength={2} value={form.state} onChange={(event) => update('state', event.target.value.toUpperCase())} /><input aria-label="WhatsApp" placeholder="WhatsApp *" value={form.whatsapp} onChange={(event) => update('whatsapp', event.target.value)} /><input aria-label="E-mail" placeholder="E-mail (opcional)" type="email" value={form.email} onChange={(event) => update('email', event.target.value)} /><textarea aria-label="Mensagem" placeholder="Como podemos ajudar?" value={form.message} onChange={(event) => update('message', event.target.value)} /></div><a className="button button-primary form-submit" href={wa(partnershipMessage())}>Enviar pelo WhatsApp <ArrowUpRight size={18} /></a><small>Ao enviar, você será direcionado ao WhatsApp comercial da Doc Motor.</small></div></div></section>
    </main>
    <footer className="footer"><div className="container footer-top"><div className="footer-brand"><BrandLogo /><p>Documentação veicular com clareza, responsabilidade e direção.</p></div><div className="footer-links"><div><strong>Explorar</strong><a href="#servicos">Serviços</a><a href="#como-funciona">Como funciona</a><a href="#parceiro">Seja parceiro</a></div><div><strong>Atendimento</strong><a href="#faq">Perguntas frequentes</a><a href="#contato">Contato</a><a href="/area-do-parceiro">Área do parceiro</a></div><div><strong>Legal</strong><a href="#contato">Política de privacidade</a><a href="#contato">Termos de uso</a></div></div></div><div className="container footer-bottom"><span>© 2026 Doc Motor. Informação sujeita à análise do caso concreto.</span><span>Feito para mover.</span></div></footer><a className="floating-whatsapp" href={wa('Olá, Doc Motor! Gostaria de falar com um especialista.')} aria-label="Falar com a Doc Motor pelo WhatsApp"><MessageCircle size={24} /></a>
  </div>
}

function App() {
  const path = window.location.pathname
  if (path === '/login') return <LoginPage />
  if (path === '/cadastro-cliente') return <ClientRegistrationPage />
  if (path === '/cadastro-parceiro') return <PartnerRegistrationPage />
  if (path === '/aguardando-aprovacao') return <StatusPage title="Cadastro recebido." text="Seu interesse foi registrado e aguarda aprovação administrativa. Você poderá entrar quando o acesso for liberado." href="/login" />
  if (path === '/acesso-nao-autorizado') return <StatusPage title="Acesso não autorizado." text="Seu perfil não possui permissão para esta área." href="/" />
  if (path === '/admin') return <DashboardPage role="ADMINISTRATOR" />
  if (path === '/parceiro') return <DashboardPage role="PARTNER" />
  if (path === '/cliente') return <DashboardPage role="CLIENT" />
  if (path === '/recuperar-senha') return <PasswordRecoveryPage />
  if (path === '/redefinir-senha') return <ResetPasswordPage />
  return <CommercialApp />
}

export default App
